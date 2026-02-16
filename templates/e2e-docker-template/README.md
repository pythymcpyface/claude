# E2E Docker Test Template

A reusable template for generating full-stack E2E testing infrastructure with Docker orchestration.

## Overview

This template generates a complete E2E testing suite that includes:

- **Docker Compose** configuration for test environment orchestration
- **Playwright** test framework with Page Object Model
- **Database utilities** for seeding and resetting test data
- **CI/CD workflows** for GitHub Actions
- **Health check orchestration** for reliable test execution

## Quick Start

```bash
# In your project directory
/create-e2e-docker

# Or with a config file
/create-e2e-docker --config e2e-config.json
```

## Template Structure

```
e2e-docker-template/
├── config-schema.json          # JSON schema for configuration
├── README.md                   # This file
└── template/
    ├── docker-compose.test.yml.ejs
    ├── scripts/
    │   ├── run-e2e.sh.ejs
    │   └── e2e-db-reset.ts.ejs
    ├── tests/
    │   └── e2e-docker/
    │       ├── playwright.config.ts.ejs
    │       ├── global-setup.ts.ejs
    │       ├── global-teardown.ts.ejs
    │       ├── fixtures/
    │       │   └── index.ts.ejs
    │       ├── helpers/
    │       │   └── auth.ts.ejs
    │       ├── pages/
    │       │   ├── base.page.ts.ejs
    │       │   └── login.page.ts.ejs
    │       └── specs/
    │           └── auth.spec.ts.ejs
    └── .github/
        └── workflows/
            └── e2e-docker.yml.ejs
```

## Configuration Options

### Project Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `projectName` | string | *required* | Project name in kebab-case |

### Database Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.database.type` | string | `postgres` | Database type: postgres, mysql, mongodb |
| `services.database.image` | string | `postgres:16-alpine` | Docker image |
| `services.database.port` | number | `5433` | Host port (non-standard to avoid conflicts) |
| `services.database.user` | string | `test_user` | Database username |
| `services.database.password` | string | `test_password` | Database password |
| `services.database.database` | string | `test_db` | Database name |
| `services.database.useTmpfs` | boolean | `true` | Use RAM-based storage |

### API Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.api.port` | number | `3001` | Host port |
| `services.api.internalPort` | number | `3000` | Container port |
| `services.api.healthEndpoint` | string | `/health` | Health check endpoint |
| `services.api.dockerfile` | string | `Dockerfile` | Dockerfile name |
| `services.api.buildContext` | string | `.` | Build context path |
| `services.api.envVars` | object | `{}` | Additional environment variables |

### Frontend Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.frontend.port` | number | `5174` | Host port |
| `services.frontend.internalPort` | number | `5173` | Container port |
| `services.frontend.framework` | string | `vite` | Framework: vite, react, next, nuxt, vue, svelte |
| `services.frontend.dockerfile` | string | `Dockerfile` | Dockerfile name |
| `services.frontend.buildContext` | string | `./frontend` | Build context path |
| `services.frontend.dockerfileTarget` | string | `development` | Dockerfile target stage |

### Test Users

```json
"testUsers": [
  {
    "email": "test-user@example.com",
    "password": "TestPassword123!",
    "name": "Test User",
    "role": "user",
    "verified": true
  }
]
```

### CI Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `ci.provider` | string | `github` | CI provider: github, gitlab, circleci, none |
| `ci.nodeVersion` | string | `20` | Node.js version |
| `ci.browsers` | array | `["chromium"]` | Browser matrix |
| `ci.timeoutMinutes` | number | `30` | Job timeout |

## Template Variables

The following EJS variables are available in templates:

| Variable | Description |
|----------|-------------|
| `projectName` | Project name |
| `services` | Service configurations |
| `services.database` | Database configuration |
| `services.api` | API configuration |
| `services.frontend` | Frontend configuration |
| `testUsers` | Array of test users |
| `auth` | Authentication settings |
| `ci` | CI configuration |
| `testing` | Testing configuration |
| `secrets` | Array of secret environment variable names |

## Customization

### Adding New Page Objects

Create a new file in `tests/e2e-docker/pages/`:

```typescript
import { BasePage } from "./base.page";
import { Page, Locator } from "@playwright/test";

export class DashboardPage extends BasePage {
  private readonly welcomeMessage: Locator;

  constructor(page: Page) {
    super(page, "/dashboard");
    this.welcomeMessage = page.getByRole("heading", { name: /welcome/i });
  }

  async expectWelcomeVisible(): Promise<void> {
    await expect(this.welcomeMessage).toBeVisible();
  }
}
```

### Adding New Test Fixtures

Extend the fixtures in `tests/e2e-docker/fixtures/index.ts`:

```typescript
export const test = base.extend<E2EFixtures>({
  // Add new fixture
  adminPage: async ({ page }, use) => {
    await performLogin(page, TEST_USERS.admin.email, TEST_USERS.admin.password);
    await use(page);
  },
});
```

### Customizing Database Seed

Modify `scripts/e2e-db-reset.ts` to add your schema-specific seed data:

```typescript
// Add custom seed data after truncating tables
await client.query(
  `INSERT INTO products (name, price) VALUES ($1, $2)`,
  ['Test Product', 9.99]
);
```

## Architecture Decisions

### Why tmpfs?

Using tmpfs for database storage provides:
- **Speed**: RAM is 10-100x faster than disk
- **Isolation**: Each test run starts fresh
- **Cleanup**: Data is automatically destroyed when container stops

### Why External Orchestration?

The `run-e2e.sh` script manages containers rather than Playwright's `webServer`:
- **Full control**: Explicit health checks and timing
- **Debugging**: Keep containers running for inspection
- **Reusability**: Same containers for local and CI testing

### Why Page Object Model?

- **Maintainability**: UI changes in one place
- **Readability**: Tests read like user stories
- **Reusability**: Common interactions shared across tests

## Troubleshooting

### Container Health Checks Fail

```bash
# Check container logs
docker-compose -f docker-compose.test.yml logs app

# Run with debug mode
KEEP_CONTAINERS=true ./scripts/run-e2e.sh
docker-compose -f docker-compose.test.yml logs
```

### Database Connection Issues

```bash
# Verify database is accessible
docker exec -it <project>-test-db psql -U test_user -d test_db

# Check network connectivity
docker network inspect <project>-test-network
```

### Playwright Timeouts

Increase timeouts in `playwright.config.ts`:
```typescript
export default defineConfig({
  timeout: 60000, // 60 seconds
  use: {
    actionTimeout: 30000,
    navigationTimeout: 60000,
  },
});
```

## License

MIT
