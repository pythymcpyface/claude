# Generate E2E Tests Command

## Purpose
Automatically set up end-to-end (E2E) testing infrastructure with Playwright or Cypress, including configuration, fixtures, Page Object Models, and CI/CD integration.

## Problem Solved
Setting up E2E test infrastructure is:
- **Repetitive**: Same boilerplate setup across projects
- **Error-prone**: Easy to misconfigure Playwright/Cypress
- **Time-consuming**: Takes 6-10 hours to set up properly
- **Complex**: Many moving parts (config, fixtures, POM, CI/CD)

## Usage
```
/generate-e2e-tests [framework]
```

**Arguments:**
- `framework`: (Optional) Test framework to use. Options: `playwright` (default), `cypress`

## Workflow

### Step 1: Detect Project Type
Automatically detect the project framework and configuration.

**Detection criteria:**
- Check `package.json` for framework indicators
- Identify Next.js (`next.config.js`), React (`react`), Vue (`vue`), etc.
- Detect TypeScript vs JavaScript
- Find existing test configuration

**Output:**
```
Detected project:
- Framework: Next.js 14 (App Router)
- Language: TypeScript
- Package Manager: pnpm
- Existing tests: Jest (unit tests)
```

### Step 2: Install Test Framework
Install Playwright or Cypress with appropriate dependencies.

**For Playwright:**
```bash
npm install -D @playwright/test
npx playwright install --with-deps
```

**For Cypress:**
```bash
npm install -D cypress
```

**Additional dependencies:**
- `@types/node` (if TypeScript)
- `dotenv` (for environment variables)
- `axe-playwright` or `cypress-axe` (accessibility testing)

### Step 3: Generate Configuration
Create framework configuration with recommended settings.

**Playwright configuration:**
```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';
import dotenv from 'dotenv';

dotenv.config({ path: '.env.test' });

export default defineConfig({
  testDir: './e2e/tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['junit', { outputFile: 'test-results/junit.xml' }]
  ],

  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    // Mobile viewports
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

**Cypress configuration:**
```typescript
// cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,

    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
```

### Step 4: Create Fixtures Directory
Generate reusable test fixtures for common operations.

**File structure:**
```
e2e/fixtures/
├── auth.ts           # Authentication helpers
├── database.ts       # Database seeding and cleanup
├── api.ts            # API mocking
└── users.ts          # User test data
```

**Auth fixtures:**
```typescript
// e2e/fixtures/auth.ts
import { Page } from '@playwright/test';

export const testUsers = {
  admin: {
    email: 'admin@test.com',
    password: 'admin123!',
    role: 'admin',
  },
  regular: {
    email: 'user@test.com',
    password: 'user123!',
    role: 'user',
  },
} as const;

export async function login(page: Page, userType: keyof typeof testUsers) {
  const user = testUsers[userType];

  await page.goto('/login');
  await page.fill('[name=email]', user.email);
  await page.fill('[name=password]', user.password);
  await page.click('button[type=submit]');

  // Wait for redirect
  await page.waitForURL(/.*dashboard/);
}

export async function logout(page: Page) {
  await page.click('[data-testid=user-menu]');
  await page.click('[data-testid=logout-button]');
  await page.waitForURL('/login');
}

export async function isAuthenticated(page: Page): Promise<boolean> {
  return page.locator('[data-testid=user-menu]').isVisible();
}
```

**Database fixtures:**
```typescript
// e2e/fixtures/database.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasourceUrl: process.env.DATABASE_URL_TEST,
});

export async function seedDatabase() {
  // Clean existing data
  await prisma.post.deleteMany();
  await prisma.user.deleteMany();

  // Seed test users
  await prisma.user.createMany({
    data: [
      {
        email: 'admin@test.com',
        password: '$2a$10$...', // hashed password
        role: 'admin',
      },
      {
        email: 'user@test.com',
        password: '$2a$10$...',
        role: 'user',
      },
    ],
  });
}

export async function cleanDatabase() {
  await prisma.$transaction([
    prisma.post.deleteMany(),
    prisma.user.deleteMany(),
  ]);
}

export async function disconnect() {
  await prisma.$disconnect();
}
```

**API mocking fixtures:**
```typescript
// e2e/fixtures/api.ts
import { Page } from '@playwright/test';

export async function mockApiResponse(
  page: Page,
  url: string,
  response: any,
  status = 200
) {
  await page.route(url, (route) => {
    route.fulfill({
      status,
      contentType: 'application/json',
      body: JSON.stringify(response),
    });
  });
}

export async function mockApiError(page: Page, url: string, status = 500) {
  await page.route(url, (route) => {
    route.fulfill({
      status,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal Server Error' }),
    });
  });
}
```

### Step 5: Create Page Object Models
Generate Page Object Models for key UI components.

**File structure:**
```
e2e/page-objects/
├── BasePage.ts       # Base class with common methods
├── HomePage.ts       # Home/landing page
├── LoginPage.ts      # Authentication pages
├── DashboardPage.ts  # Main dashboard
└── ProfilePage.ts    # User profile
```

**Base page:**
```typescript
// e2e/page-objects/BasePage.ts
import { Page, Locator } from '@playwright/test';

export class BasePage {
  constructor(protected page: Page) {}

  async goto(path: string) {
    await this.page.goto(path);
  }

  async waitForLoadState() {
    await this.page.waitForLoadState('networkidle');
  }

  async getByTestId(testId: string): Promise<Locator> {
    return this.page.locator(`[data-testid="${testId}"]`);
  }

  async fillForm(data: Record<string, string>) {
    for (const [field, value] of Object.entries(data)) {
      await this.page.fill(`[name="${field}"]`, value);
    }
  }

  async screenshot(name: string) {
    await this.page.screenshot({ path: `screenshots/${name}.png` });
  }
}
```

**Login page:**
```typescript
// e2e/page-objects/LoginPage.ts
import { Page, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class LoginPage extends BasePage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.locator('[name=email]');
    this.passwordInput = page.locator('[name=password]');
    this.submitButton = page.locator('button[type=submit]');
    this.errorMessage = page.locator('[data-testid=error-message]');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }

  async expectRedirect(url: RegExp) {
    await this.page.waitForURL(url);
  }
}
```

**Dashboard page:**
```typescript
// e2e/page-objects/DashboardPage.ts
import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class DashboardPage extends BasePage {
  readonly userMenu: Locator;
  readonly welcomeMessage: Locator;
  readonly createButton: Locator;

  constructor(page: Page) {
    super(page);
    this.userMenu = page.locator('[data-testid=user-menu]');
    this.welcomeMessage = page.locator('[data-testid=welcome]');
    this.createButton = page.locator('[data-testid=create-button]');
  }

  async goto() {
    await this.page.goto('/dashboard');
  }

  async expectWelcomeMessage(userName: string) {
    await expect(this.welcomeMessage).toContainText(`Welcome, ${userName}`);
  }

  async createNewItem() {
    await this.createButton.click();
    await this.page.waitForURL(/.*\/create/);
  }
}
```

### Step 6: Generate Example E2E Tests
Create example tests for critical user journeys.

**File structure:**
```
e2e/tests/
├── auth.spec.ts            # Authentication flows
├── critical-flows.spec.ts  # Main user journeys
└── accessibility.spec.ts   # A11y tests
```

**Authentication tests:**
```typescript
// e2e/tests/auth.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../page-objects/LoginPage';
import { DashboardPage } from '../page-objects/DashboardPage';
import { testUsers } from '../fixtures/auth';
import { seedDatabase, cleanDatabase } from '../fixtures/database';

test.describe('Authentication', () => {
  test.beforeEach(async () => {
    await seedDatabase();
  });

  test.afterEach(async () => {
    await cleanDatabase();
  });

  test('user can login with valid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);
    const dashboardPage = new DashboardPage(page);

    await loginPage.goto();
    await loginPage.login(testUsers.regular.email, testUsers.regular.password);

    await dashboardPage.expectWelcomeMessage('User');
    await expect(dashboardPage.userMenu).toBeVisible();
  });

  test('user cannot login with invalid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.goto();
    await loginPage.login('wrong@test.com', 'wrongpassword');

    await loginPage.expectError('Invalid email or password');
  });

  test('user can logout', async ({ page }) => {
    const loginPage = new LoginPage(page);
    const dashboardPage = new DashboardPage(page);

    // Login
    await loginPage.goto();
    await loginPage.login(testUsers.regular.email, testUsers.regular.password);

    // Logout
    await dashboardPage.userMenu.click();
    await page.click('[data-testid=logout-button]');

    // Verify redirect
    await expect(page).toHaveURL('/login');
  });
});
```

**Critical flows:**
```typescript
// e2e/tests/critical-flows.spec.ts
import { test, expect } from '@playwright/test';
import { login } from '../fixtures/auth';

test.describe('Critical User Flows', () => {
  test('user can create, view, and delete an item', async ({ page }) => {
    await login(page, 'regular');

    // Create item
    await page.click('[data-testid=create-button]');
    await page.fill('[name=title]', 'Test Item');
    await page.fill('[name=description]', 'Test Description');
    await page.click('button[type=submit]');

    // Verify creation
    await expect(page.locator('text=Test Item')).toBeVisible();

    // View item
    await page.click('text=Test Item');
    await expect(page.locator('[data-testid=item-title]')).toHaveText('Test Item');

    // Delete item
    await page.click('[data-testid=delete-button]');
    await page.click('[data-testid=confirm-delete]');

    // Verify deletion
    await expect(page.locator('text=Test Item')).not.toBeVisible();
  });
});
```

### Step 7: Add Test Scripts to package.json
Update package.json with test commands.

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug",
    "test:e2e:headed": "playwright test --headed",
    "test:e2e:report": "playwright show-report"
  }
}
```

### Step 8: Update CI/CD Pipeline
Generate GitHub Actions workflow for E2E tests.

```yaml
# .github/workflows/e2e-tests.yml
name: E2E Tests

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  e2e:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Setup test database
        env:
          DATABASE_URL_TEST: postgresql://postgres:postgres@localhost:5432/test_db
        run: |
          npx prisma migrate deploy
          npx prisma db seed

      - name: Run E2E tests
        env:
          BASE_URL: http://localhost:3000
          DATABASE_URL_TEST: postgresql://postgres:postgres@localhost:5432/test_db
        run: npm run test:e2e

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

### Step 9: Generate E2E Testing Guide
Create comprehensive documentation.

```markdown
# E2E Testing Guide

## Setup
```bash
npm install
npx playwright install
```

## Running Tests
```bash
# Run all tests
npm run test:e2e

# Run in UI mode (recommended for development)
npm run test:e2e:ui

# Run in headed mode (see browser)
npm run test:e2e:headed

# Run specific test file
npx playwright test e2e/tests/auth.spec.ts

# Debug specific test
npm run test:e2e:debug
```

## Writing Tests

### Use Page Object Models
```typescript
import { LoginPage } from '../page-objects/LoginPage';

test('example', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@test.com', 'password');
});
```

### Use Fixtures for Setup
```typescript
import { login } from '../fixtures/auth';

test('example', async ({ page }) => {
  await login(page, 'regular');
  // Test authenticated flow
});
```

## Best Practices
1. Use `data-testid` for selecting elements
2. Avoid hardcoded waits - use `waitFor` methods
3. Clean database between tests
4. Use Page Object Models for reusability
5. Test critical flows only (5-10% of functionality)
```

## Files Created

1. **Configuration**
   - `playwright.config.ts` or `cypress.config.ts`
   - `.env.test` (environment variables template)

2. **Fixtures**
   - `e2e/fixtures/auth.ts`
   - `e2e/fixtures/database.ts`
   - `e2e/fixtures/api.ts`
   - `e2e/fixtures/users.ts`

3. **Page Object Models**
   - `e2e/page-objects/BasePage.ts`
   - `e2e/page-objects/LoginPage.ts`
   - `e2e/page-objects/DashboardPage.ts`
   - `e2e/page-objects/ProfilePage.ts`

4. **Tests**
   - `e2e/tests/auth.spec.ts`
   - `e2e/tests/critical-flows.spec.ts`
   - `e2e/tests/accessibility.spec.ts`

5. **CI/CD**
   - `.github/workflows/e2e-tests.yml`

6. **Documentation**
   - `E2E_TESTING_GUIDE.md`

## Benefits

- **Faster Setup**: 6-10 hours → 1 hour
- **Best Practices**: Baked-in patterns and conventions
- **CI/CD Ready**: GitHub Actions workflow included
- **Maintainable**: Page Object Models and fixtures
- **Comprehensive**: Auth, database, API mocking covered

## Example Usage

```bash
# Generate Playwright E2E tests (default)
/generate-e2e-tests

# Generate Cypress E2E tests
/generate-e2e-tests cypress
```
