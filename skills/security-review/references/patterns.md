# security-review — Implementation Patterns

Reusable code snippets and configuration templates for security-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### Input Validation with Zod

```typescript
// src/schemas/user.schema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(128)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[a-z]/, 'Must contain lowercase')
    .regex(/[0-9]/, 'Must contain number')
    .regex(/[^A-Za-z0-9]/, 'Must contain special character'),
  name: z.string().min(1).max(100).regex(/^[\w\s-]+$/),
  age: z.number().int().min(0).max(150).optional(),
});

// Usage in route
app.post('/users', validate(createUserSchema), createUserHandler);
```

### Password Hashing with bcrypt

```typescript
// src/services/password.ts
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

export async function hashPassword(plainPassword: string): Promise<string> {
  return bcrypt.hash(plainPassword, SALT_ROUNDS);
}

export async function verifyPassword(
  plainPassword: string,
  hashedPassword: string
): Promise<boolean> {
  return bcrypt.compare(plainPassword, hashedPassword);
}
```

### JWT Authentication

```typescript
// src/services/jwt.ts
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET!;
const JWT_EXPIRES_IN = '15m';
const REFRESH_EXPIRES_IN = '7d';

export function generateAccessToken(userId: string): string {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

export function generateRefreshToken(userId: string): string {
  return jwt.sign({ userId, type: 'refresh' }, JWT_SECRET, { 
    expiresIn: REFRESH_EXPIRES_IN 
  });
}

export function verifyToken(token: string): { userId: string } {
  return jwt.verify(token, JWT_SECRET) as { userId: string };
}
```

### Security Headers with Helmet

```typescript
// src/middleware/security.ts
import helmet from 'helmet';
import cors from 'cors';

app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:'],
    connectSrc: ["'self'"],
    fontSrc: ["'self'"],
    objectSrc: ["'none'"],
    frameAncestors: ["'none'"],
  },
}));

const allowedOrigins = ['https://app.example.com'];
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
}));
```

### Rate Limiting

```typescript
// src/middleware/rateLimit.ts
import rateLimit from 'express-rate-limit';

// General API rate limit
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: { error: 'Too many requests' },
});

// Stricter auth rate limit
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 login attempts per 15 minutes
  skipSuccessfulRequests: true,
});

app.use('/api/', apiLimiter);
app.use('/auth/login', authLimiter);
```

### SQL Injection Prevention

```typescript
// BAD - vulnerable to SQL injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// GOOD - parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);

// Using an ORM (Prisma)
const user = await prisma.user.findUnique({
  where: { id: userId },
});
```

### XSS Prevention

```typescript
// Server-side output encoding
import { escape } from 'html-escaper';

function sanitizeOutput(userInput: string): string {
  return escape(userInput);
}

// React automatically escapes
<div>{userInput}</div>

// When you MUST use HTML, sanitize first
import DOMPurify from 'dompurify';

function safeHTML(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href'],
  });
}
```

### CSRF Protection

```typescript
// src/middleware/csrf.ts
import csrf from 'csurf';

const csrfProtection = csrf({ cookie: true });

app.get('/api/csrf-token', csrfProtection, (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

// Protected routes
app.post('/api/data', csrfProtection, (req, res) => {
  // CSRF token validated
});
```

### Secrets from Environment

```typescript
// BAD - hardcoded secret
const apiKey = 'sk-live-abc123xyz';

// GOOD - from environment
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error('API_KEY environment variable not set');
}

// Using dotenv for local development
import 'dotenv/config';

// Validation with zod
const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  API_KEY: z.string().min(1),
});

const env = envSchema.parse(process.env);
```

---

