# create-e2e-docker - E2E Docker Test Suite Generator

Generate a complete E2E Docker testing infrastructure for full-stack applications.

## Usage

```
/create-e2e-docker [options]
/create-e2e-docker --config path/to/config.json
```

## What This Command Does

1. Prompts for configuration (or accepts config file)
2. Generates Docker Compose test configuration
3. Creates Playwright test infrastructure
4. Generates Page Object Model templates
5. Creates CI/CD workflow files
6. Provides next steps for customization

## Generated Files

```
project/
├── docker-compose.test.yml      # Test environment orchestration
├── scripts/
│   ├── run-e2e.sh               # Test runner with health checks
│   └── e2e-db-reset.ts          # Database seeding utility
├── tests/
│   └── e2e-docker/
│       ├── playwright.config.ts # Playwright configuration
│       ├── global-setup.ts      # Pre-test verification
│       ├── global-teardown.ts   # Post-test cleanup
│       ├── fixtures/
│       │   └── index.ts         # Test fixtures (auth, API)
│       ├── helpers/
│       │   └── auth.ts          # Auth utilities
│       ├── pages/
│       │   ├── base.page.ts     # Base page object
│       │   └── login.page.ts    # Login page object
│       └── specs/
│           └── auth.spec.ts     # Sample auth tests
└── .github/
    └── workflows/
        └── e2e-docker.yml       # CI/CD workflow
```

## Configuration

The generator accepts a JSON configuration file with the following schema:

```json
{
  "projectName": "my-app",
  "services": {
    "database": {
      "type": "postgres",
      "image": "postgres:16-alpine",
      "port": 5433,
      "user": "test_user",
      "password": "test_password",
      "database": "test_db",
      "useTmpfs": true
    },
    "api": {
      "port": 3001,
      "internalPort": 3000,
      "healthEndpoint": "/health",
      "dockerfile": "Dockerfile",
      "buildContext": "."
    },
    "frontend": {
      "port": 5174,
      "internalPort": 5173,
      "framework": "vite",
      "dockerfile": "Dockerfile",
      "buildContext": "./frontend"
    }
  },
  "testUsers": [
    {
      "email": "test-user@example.com",
      "password": "TestPassword123!",
      "name": "Test User",
      "role": "user",
      "verified": true
    }
  ],
  "auth": {
    "loginPath": "/login",
    "dashboardPath": "/dashboard"
  },
  "ci": {
    "provider": "github",
    "nodeVersion": "20",
    "browsers": ["chromium"]
  }
}
```

---

## Execution Instructions

When this command is invoked, follow these steps:

### Step 1: Gather Configuration

Ask the user if they want to:
1. **Use a config file** - Provide path to JSON config
2. **Interactive configuration** - Answer prompts
3. **Use defaults** - Generate with sensible defaults

If interactive, ask:
- Project name (kebab-case)
- Database type (postgres/mysql/mongodb)
- Frontend framework (vite/react/next/vue/svelte)
- Test user credentials

### Step 2: Prepare Configuration Object

Create a complete configuration with defaults:

```javascript
const config = {
  projectName: "<from user>",
  services: {
    database: {
      type: "postgres",
      image: "postgres:16-alpine",
      port: 5433,
      user: "test_user",
      password: "test_password",
      database: "test_db",
      useTmpfs: true,
      ...userConfig.services?.database
    },
    api: {
      port: 3001,
      internalPort: 3000,
      healthEndpoint: "/health",
      dockerfile: "Dockerfile",
      buildContext: ".",
      envVars: {},
      ...userConfig.services?.api
    },
    frontend: {
      port: 5174,
      internalPort: 5173,
      framework: "vite",
      dockerfile: "Dockerfile",
      buildContext: "./frontend",
      dockerfileTarget: "development",
      envVars: {},
      ...userConfig.services?.frontend
    }
  },
  testUsers: userConfig.testUsers || [
    { email: "test-user@example.com", password: "TestPassword123!", name: "Test User", role: "user", verified: true },
    { email: "test-admin@example.com", password: "TestPassword123!", name: "Test Admin", role: "admin", verified: true }
  ],
  auth: {
    tokenStorageKey: "access_token",
    refreshTokenKey: "refresh_token",
    loginPath: "/login",
    dashboardPath: "/dashboard",
    ...userConfig.auth
  },
  ci: {
    provider: "github",
    nodeVersion: "20",
    browsers: ["chromium"],
    timeoutMinutes: 30,
    ...userConfig.ci
  },
  testing: {
    workers: 4,
    retries: 2,
    timeout: 30000,
    reportDir: "reports/e2e",
    ...userConfig.testing
  },
  secrets: userConfig.secrets || []
};
```

### Step 3: Generate Files

Read templates from `~/.claude/templates/e2e-docker-template/template/` and process with EJS:

```javascript
const ejs = require('ejs');
const fs = require('fs');
const path = require('path');

const templateDir = path.join(process.env.HOME, '.claude/templates/e2e-docker-template/template');

// List of template files to process
const templates = [
  'docker-compose.test.yml.ejs',
  'scripts/run-e2e.sh.ejs',
  'scripts/e2e-db-reset.ts.ejs',
  'tests/e2e-docker/playwright.config.ts.ejs',
  'tests/e2e-docker/global-setup.ts.ejs',
  'tests/e2e-docker/global-teardown.ts.ejs',
  'tests/e2e-docker/fixtures/index.ts.ejs',
  'tests/e2e-docker/helpers/auth.ts.ejs',
  'tests/e2e-docker/pages/base.page.ts.ejs',
  'tests/e2e-docker/pages/login.page.ts.ejs',
  'tests/e2e-docker/specs/auth.spec.ts.ejs',
  '.github/workflows/e2e-docker.yml.ejs'
];

for (const templatePath of templates) {
  const template = fs.readFileSync(path.join(templateDir, templatePath), 'utf8');
  const rendered = ejs.render(template, config);
  const outputPath = templatePath.replace('.ejs', '');
  // Write to target project directory
}
```

### Step 4: Install Dependencies

Add the following to package.json devDependencies:

```json
{
  "devDependencies": {
    "@playwright/test": "^1.40.0",
    "bcrypt": "^5.1.1",
    "dotenv": "^16.3.1",
    "tsx": "^4.7.0"
  }
}
```

For PostgreSQL:
```json
"pg": "^8.11.3"
```

For MySQL:
```json
"mysql2": "^3.6.5"
```

For MongoDB:
```json
"mongodb": "^6.3.0"
```

Add scripts to package.json:

```json
{
  "scripts": {
    "test:e2e:docker": "./scripts/run-e2e.sh",
    "test:e2e:docker:debug": "KEEP_CONTAINERS=true ./scripts/run-e2e.sh"
  }
}
```

### Step 5: Output Summary

After generation, display:

```
========================================
E2E Docker Test Suite Generated
========================================

Files created:
  - docker-compose.test.yml
  - scripts/run-e2e.sh
  - scripts/e2e-db-reset.ts
  - tests/e2e-docker/ (9 files)

Next steps:
1. npm install
2. npx playwright install
3. Ensure your Dockerfile builds are working
4. Customize e2e-db-reset.ts for your schema
5. Update page objects for your UI
6. Run: ./scripts/run-e2e.sh

Configuration saved to: .e2e-docker-config.json
```

## Key Features

- **tmpfs Database**: RAM-based storage for fast ephemeral tests
- **Health Checks**: Automatic service readiness verification
- **Test Isolation**: Fresh database state for each run
- **Page Object Model**: Maintainable UI interaction patterns
- **CI/CD Ready**: GitHub Actions workflow included
- **Multi-database**: PostgreSQL, MySQL, MongoDB support
- **Multi-framework**: Vite, React, Next.js, Vue, Svelte

## Customization Points

After generation, customize:

1. **e2e-db-reset.ts**: Add your schema tables and seed data
2. **Page Objects**: Create page objects for your UI components
3. **Fixtures**: Add project-specific test fixtures
4. **CI Workflow**: Adjust for your CI provider and secrets
