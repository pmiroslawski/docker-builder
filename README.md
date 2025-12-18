# PHP-FPM Docker Builder

Multi-architecture PHP 8.4 Docker images with environment-specific configurations for development, production, and testing.

## Architecture

The project uses a layered image approach:

```
php:8.4-fpm-bookworm
        │
        ▼
    php-fpm-base          (common extensions + config)
        │
        ├──► php-fpm-dev  (Composer, Git, Node.js, Xdebug)
        │         │
        │         └──► php-fpm-testing  (Chromium, ChromeDriver)
        │
        └──► php-fpm-prod (hardened, minimal)
```

## Images

| Image | Purpose | Includes |
|-------|---------|----------|
| `php-fpm-base` | Base layer | PHP 8.4, common extensions (GD, Intl, PDO, Redis, AMQP, etc.) |
| `php-fpm-dev` | Development | Base + Composer, Git, Node.js 22, Xdebug |
| `php-fpm-prod` | Production | Base + hardened config, minimal footprint |
| `php-fpm-testing` | Browser tests | Dev + Chromium, ChromeDriver (Panther/Selenium ready) |

## PHP Extensions

Included in all images:
- bcmath, gd, gmp, imap, intl, mbstring
- opcache, pcntl, pdo, pdo_mysql, mysqli
- sockets, soap, xml, zip
- amqp, apcu, excimer, igbinary, redis

## Quick Start

### Build all images locally

```bash
./build.sh
```

### Build specific image

```bash
./build.sh base    # Only base image
./build.sh dev     # Base + dev image
./build.sh prod    # Base + prod image
./build.sh testing # Base + dev + testing image
```

### Build and push to registry

```bash
REGISTRY=ghcr.io/username/repo/ VERSION=1.0.0 ./build.sh all --push
```

This creates images tagged as `php-fpm-base:8.4-1.0.0`, `php-fpm-dev:8.4-1.0.0`, etc.

### Using with Docker Compose

**Production** (default):
```bash
docker compose up -d
```

**Development** (uses override file automatically):
```bash
docker compose up -d
# Xdebug available, volumes writable
```

**Testing** (includes Chromium):
```bash
docker compose --profile testing up -d
```

## CI/CD with GitHub Actions

Images are automatically built and pushed to GitHub Container Registry when a new version tag is pushed.

### Trigger a Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers the workflow and creates images:
- `ghcr.io/{owner}/{repo}/php-fpm-base:8.4-1.0.0`
- `ghcr.io/{owner}/{repo}/php-fpm-dev:8.4-1.0.0`
- `ghcr.io/{owner}/{repo}/php-fpm-prod:8.4-1.0.0`
- `ghcr.io/{owner}/{repo}/php-fpm-testing:8.4-1.0.0`

Plus `8.4-latest` tags for each image.

### Workflow Details

The GitHub Action (`.github/workflows/build-images.yaml`):
1. Builds images in dependency order (base → dev/prod → testing)
2. Multi-architecture support (see [Platforms](#platforms) for details)
3. Uses GitHub Actions cache for faster builds
4. Pushes to GitHub Container Registry (ghcr.io)

### Using Published Images

```bash
docker pull ghcr.io/{owner}/{repo}/php-fpm-dev:8.4-latest
```

## Configuration

### Environment Variables (build.sh)

| Variable | Default | Description |
|----------|---------|-------------|
| `REGISTRY` | `` | Registry prefix (e.g., `ghcr.io/user/repo/`) |
| `VERSION` | `latest` | Version part of the tag |
| `PHP_VERSION` | `8.4` | PHP version prefix for tags |

Image tags follow the format: `php-fpm-{name}:{PHP_VERSION}-{VERSION}`

Examples:
- `php-fpm-base:8.4-latest` (default)
- `php-fpm-dev:8.4-1.0.0`
- `php-fpm-prod:8.4-2.0.0`

### PHP Configuration

Configuration files are layered:

- `_docker/base/config/php.ini` - Common settings (memory, uploads, OPcache base)
- `_docker/dev/config/php.ini` - Development overrides (errors on, no limits)
- `_docker/dev/config/xdebug.ini` - Xdebug settings (trigger mode, port 9003)
- `_docker/prod/config/php.ini` - Production overrides (errors off, OPcache aggressive)

### Xdebug (Development)

Xdebug is configured in trigger mode:

```ini
xdebug.mode = debug,develop
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
xdebug.start_with_request = trigger
xdebug.idekey = PHPSTORM
```

To activate, use browser extension or add `XDEBUG_TRIGGER=1` to requests.

### Browser Testing (Testing Image)

Environment variables for Symfony Panther:

```bash
PANTHER_NO_SANDBOX=1
PANTHER_CHROME_DRIVER_BINARY=/usr/bin/chromedriver
PANTHER_CHROME_BINARY=/usr/bin/chromium
```

## Directory Structure

```
.
├── .github/
│   └── workflows/
│       └── build-images.yaml     # CI/CD workflow
├── _docker/
│   ├── base/
│   │   ├── Dockerfile
│   │   └── config/php.ini
│   ├── dev/
│   │   ├── Dockerfile
│   │   └── config/
│   │       ├── php.ini
│   │       └── xdebug.ini
│   ├── prod/
│   │   ├── Dockerfile
│   │   └── config/php.ini
│   └── testing/
│       └── Dockerfile
├── docker-compose.yaml           # Production config
├── docker-compose.override.yaml  # Development overrides
├── build.sh                      # Build script
└── .dockerignore
```

## Platforms

| Image | Architectures | Notes |
|-------|---------------|-------|
| `php-fpm-base` | amd64, arm64 | Required by dev/testing |
| `php-fpm-dev` | amd64, arm64 | Apple Silicon support for local development |
| `php-fpm-prod` | amd64 | Production servers typically x86 |
| `php-fpm-testing` | amd64, arm64 | Apple Silicon support for local testing |

Multi-arch builds require Docker Buildx and use `--push` flag.
