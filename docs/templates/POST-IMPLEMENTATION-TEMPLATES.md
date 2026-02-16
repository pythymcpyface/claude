# Post-Implementation Documentation Templates

Templates for documentation to be generated after Ralph Loop completes.

---

## 1. README.md Template

```markdown
# [Project Name]

[One-line description of what this project does]

## Overview

[2-3 sentence description of what this system does and why it matters]

## Features

- [Feature 1]
- [Feature 2]
- [Feature 3]

## Installation

### Prerequisites

- [Node.js version X+]
- [npm or yarn]
- [Other dependencies]

### Setup

\`\`\`bash
# Clone the repository
git clone [repository-url]
cd [project-name]

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your values

# Run setup
npm run setup
\`\`\`

## Usage

### Development

\`\`\`bash
# Run tests
npm test

# Run with watch mode
npm run test:watch

# Run linting
npm run lint

# Type check
npm run type-check

# Build
npm run build
\`\`\`

### Running the Application

\`\`\`bash
# Start the application
npm start

# Or in development mode
npm run dev
\`\`\`

## API Documentation

[If applicable, link to API.md or provide brief endpoint overview]

## Configuration

See `.env.example` for configuration options.

| Variable | Description | Default |
|----------|-------------|---------|
| `[VAR_1]` | [Description] | `[default]` |
| `[VAR_2]` | [Description] | `[default]` |

## Testing

\`\`\`bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test file
npm test -- [test-file]
\`\`\`

## Development

### Project Structure

\`\`\`
src/
├── api/           # API endpoints
├── models/        # Data models
├── services/      # Business logic
├── utils/         # Utility functions
└── middleware/    # Express middleware

tests/
├── unit/          # Unit tests
├── integration/   # Integration tests
└── e2e/           # End-to-end tests
\`\`\`

### Contributing

[If open source, include brief contribution guidelines or link to CONTRIBUTING.md]

## License

[Specify license - MIT, Apache 2.0, etc.]

## Support

[How to get help - issues, email, etc.]
```

---

## 2. API.md Template (for REST APIs)

```markdown
# API Documentation

## Base URL

\`\`\`
[Production]: https://api.example.com
[Staging]: https://staging-api.example.com
[Development]: http://localhost:3000
\`\`\`

## Authentication

Most endpoints require authentication using Bearer tokens.

\`\`\`bash
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.example.com/endpoint
\`\`\`

## Endpoints

### [Resource Name]

#### List [Resources]

\`\`\`
GET /api/[resources]
\`\`\`

**Response:**
\`\`\`json
{
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "createdAt": "ISO8601"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
\`\`\`

#### Get [Resource]

\`\`\`
GET /api/[resources]/:id
\`\`\`

**Response:**
\`\`\`json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
\`\`\`

#### Create [Resource]

\`\`\`
POST /api/[resources]
\`\`\`

**Request Body:**
\`\`\`json
{
  "name": "string",
  "description": "string"
}
\`\`\`

**Response:** `201 Created`
\`\`\`json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "createdAt": "ISO8601"
}
\`\`\`

#### Update [Resource]

\`\`\`
PATCH /api/[resources]/:id
\`\`\`

**Request Body:**
\`\`\`json
{
  "name": "string (optional)",
  "description": "string (optional)"
}
\`\`\`

**Response:** `200 OK`
\`\`\`json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "updatedAt": "ISO8601"
}
\`\`\`

#### Delete [Resource]

\`\`\`
DELETE /api/[resources]/:id
\`\`\`

**Response:** `204 No Content`

## Error Responses

All endpoints may return these error responses:

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request data |
| 401 | `UNAUTHORIZED` | Missing or invalid token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Resource not found |
| 409 | `CONFLICT` | Resource already exists |
| 500 | `INTERNAL_ERROR` | Server error |

**Error Response Format:**
\`\`\`json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}
\`\`\`

## Rate Limiting

- 100 requests per minute per IP
- 1000 requests per hour per user

Rate limit headers are included in responses:
\`\`\`
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
\`\`\`
```

---

## 3. CONTRIBUTING.md Template

```markdown
# Contributing

Thank you for your interest in contributing to [Project Name]!

## Development Setup

\`\`\`bash
# Fork and clone the repository
git clone https://github.com/yourusername/[project-name].git
cd [project-name]

# Install dependencies
npm install

# Create a branch
git checkout -b feature/your-feature-name
\`\`\`

## Code Style

- Follow the existing code style
- Run `npm run lint` before committing
- Run `npm run type-check` to verify types
- Write tests for new features
- Ensure all tests pass: `npm test`

## Commit Convention

We use conventional commits:

\`\`\`
feat: add new feature
fix: fix bug
docs: update documentation
refactor: refactor code
test: add/update tests
chore: maintenance tasks
\`\`\`

Example:
\`\`\`
git commit -m "feat(spec-023): add user authentication"
\`\`\`

## Submitting Changes

1. Ensure tests pass: `npm test`
2. Ensure lint passes: `npm run lint`
3. Push to your fork: `git push origin feature/your-feature-name`
4. Open a pull request

## Pull Request Process

- Describe your changes in the PR
- Reference any related issues
- Ensure all CI checks pass
- Wait for code review approval

## Questions?

Open an issue for questions or discussions.
```

---

## 4. DEPLOYMENT.md Template

```markdown
# Deployment Guide

## Prerequisites

- [Requirements]
- [Access to services]
- [Configuration values]

## Environment Variables

Required environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment | `production` |
| `DATABASE_URL` | Database connection | `postgresql://...` |
| `API_KEY` | External API key | `xxx` |
| `SECRET_KEY` | Signing secret | `xxx` |

## Deployment Steps

### 1. Prepare

\`\`\`bash
# Run tests
npm test

# Build
npm run build

# Verify build
ls -la dist/
\`\`\`

### 2. Deploy

#### Using [Deployment Platform]

\`\`\`bash
# Example commands
\`\`\`

### 3. Post-Deployment

\`\`\`bash
# Run migrations
npm run migrate

# Verify health
curl https://your-app.com/health

# Check logs
[platform-specific log command]
\`\`\`

## Rollback Procedure

If issues occur after deployment:

\`\`\`bash
# [Platform-specific rollback command]
\`\`\`

## Monitoring

- Health check: `GET /health`
- Metrics: `GET /metrics`
- Logs: [logging service]

## Troubleshooting

| Issue | Solution |
|-------|----------|
| [Issue 1] | [Solution] |
| [Issue 2] | [Solution] |
```

---

## 5. CHANGELOG.md Template

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- [New features]

### Changed
- [Changes to existing functionality]

### Deprecated
- [Soon-to-be removed features]

### Removed
- [Removed features]

### Fixed
- [Bug fixes]

### Security
- [Security fixes]

## [1.0.0] - YYYY-MM-DD

### Added
- Initial release
- [Core features]
```

---

*End of Post-Implementation Documentation Templates*
