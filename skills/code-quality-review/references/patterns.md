# code-quality-review — Implementation Patterns

Reusable code snippets and configuration templates for code-quality-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### Single Responsibility Principle

```typescript
// BEFORE: God class doing too much
class UserManager {
  createUser() {}
  authenticateUser() {}
  sendEmail() {}
  generateReport() {}
  validateInput() {}
  logActivity() {}
}

// AFTER: Focused classes
class UserRepository {
  create(data: UserData): User {}
  findById(id: string): User | null {}
}

class AuthenticationService {
  login(credentials: Credentials): Session {}
  logout(sessionId: string): void {}
}

class NotificationService {
  sendEmail(to: string, template: EmailTemplate): void {}
}

class AuditLogger {
  logActivity(userId: string, action: string): void {}
}
```

### Dependency Inversion

```typescript
// BEFORE: Tight coupling to concrete implementation
class OrderService {
  private stripe = new StripePaymentGateway(); // Direct dependency

  async processOrder(order: Order) {
    return this.stripe.charge(order.amount);
  }
}

// AFTER: Depend on abstraction
interface PaymentGateway {
  charge(amount: number): Promise<PaymentResult>;
}

class OrderService {
  constructor(private readonly paymentGateway: PaymentGateway) {}

  async processOrder(order: Order) {
    return this.paymentGateway.charge(order.amount);
  }
}

// Usage with dependency injection
const orderService = new OrderService(new StripePaymentGateway());
```

### Type-Safe Input Validation

```typescript
import { z } from 'zod';

// Define schema
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150).optional(),
});

type User = z.infer<typeof UserSchema>;

// Type-safe parsing
function parseUser(input: unknown): User {
  return UserSchema.parse(input); // Throws on invalid
}

// Safe parsing
function safeParseUser(input: unknown): User | null {
  const result = UserSchema.safeParse(input);
  return result.success ? result.data : null;
}
```

### Null Safety Patterns

```typescript
// BEFORE: Unsafe property access
const street = user.address.street; // Crashes if address is null

// AFTER: Safe navigation
const street = user.address?.street; // Returns undefined if address is null

// BEFORE: Unsafe assertion
const element = document.getElementById('myId')!;
element.click(); // Crashes if element not found

// AFTER: Null check
const element = document.getElementById('myId');
if (element) {
  element.click();
}

// Type guard for narrowing
function isUser(value: unknown): value is User {
  return typeof value === 'object'
    && value !== null
    && 'id' in value
    && 'email' in value;
}

function process(input: unknown) {
  if (isUser(input)) {
    console.log(input.email); // TypeScript knows it's User
  }
}
```

### DRY - Extract Shared Logic

```typescript
// BEFORE: Duplicated validation
function validateUser(data: any) {
  if (!data.email || !data.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!data.name || data.name.length < 2) {
    throw new Error('Name too short');
  }
  return data;
}

function validateAdmin(data: any) {
  if (!data.email || !data.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!data.name || data.name.length < 2) {
    throw new Error('Name too short');
  }
  if (!data.permissions || data.permissions.length === 0) {
    throw new Error('No permissions');
  }
  return data;
}

// AFTER: Composable validation
const emailValidator = z.string().email();
const nameValidator = z.string().min(2);

const UserSchema = z.object({
  email: emailValidator,
  name: nameValidator,
});

const AdminSchema = z.object({
  email: emailValidator,
  name: nameValidator,
  permissions: z.array(z.string()).min(1),
});

function validateUser(data: unknown): User {
  return UserSchema.parse(data);
}

function validateAdmin(data: unknown): Admin {
  return AdminSchema.parse(data);
}
```

### ESLint Configuration

```json
// .eslintrc.json
{
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "@typescript-eslint/recommended-requiring-type-checking",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/prefer-nullish-coalescing": "error",
    "@typescript-eslint/prefer-optional-chain": "error",
    "no-magic-numbers": ["warn", { "ignore": [0, 1, -1] }],
    "max-lines-per-function": ["warn", 50],
    "max-classes-per-file": ["error", 1],
    "complexity": ["warn", 10]
  }
}
```

### Python Type Hints

```python
from typing import Optional, List, Dict, Any
from dataclasses import dataclass
from pydantic import BaseModel, EmailStr, validator

# BEFORE: No type hints
def process_user(data):
    return {"name": data["name"], "email": data["email"]}

# AFTER: Full type hints
@dataclass
class User:
    id: str
    name: str
    email: str
    age: Optional[int] = None

def process_user(data: Dict[str, Any]) -> User:
    return User(
        id=data["id"],
        name=data["name"],
        email=data["email"],
        age=data.get("age"),
    )

# With Pydantic for validation
class UserModel(BaseModel):
    id: str
    name: str
    email: EmailStr
    age: Optional[int] = None

    @validator('age')
    def validate_age(cls, v):
        if v is not None and v < 0:
            raise ValueError('Age must be positive')
        return v
```

### Go Error Handling

```go
// BEFORE: Ignoring errors
data, _ := os.ReadFile("config.json")

// AFTER: Proper error handling
data, err := os.ReadFile("config.json")
if err != nil {
    return fmt.Errorf("failed to read config: %w", err)
}

// With custom error types
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

func validateUser(u *User) error {
    if u.Email == "" {
        return &ValidationError{Field: "email", Message: "required"}
    }
    return nil
}
```

---

