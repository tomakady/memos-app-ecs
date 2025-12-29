# Pin Alpine base image SHA for security and reproducibility
ARG ALPINE_SHA=sha256:6baf43584bcb78f2e5847d1de515f23499913ac9f12bdf834811a3145eb11ca1

# Stage 1: Build frontend React application
FROM node:20-alpine AS frontend
# Set working directory for frontend build
WORKDIR /build
# Install pnpm package manager globally
RUN npm install -g pnpm
# Copy package files first for better layer caching
COPY memos/web/package.json memos/web/pnpm-lock.yaml ./web/
# Install frontend dependencies with BuildKit cache mount for faster rebuilds
RUN --mount=type=cache,target=/root/.local/share/pnpm/store cd web && pnpm install --frozen-lockfile
# Copy frontend source code
COPY memos/web ./web
# Build frontend and output to server/router/frontend/dist
RUN cd web && pnpm run release

# Stage 2: Build backend Go application
FROM golang:1.23-alpine AS backend
# Set working directory for backend build
WORKDIR /build
# Install build dependencies (git for Go modules, ca-certificates for HTTPS)
RUN apk add --no-cache git ca-certificates
# Enable Go toolchain to auto-download required Go version if needed
ENV GOTOOLCHAIN=auto
# Copy Go module files for dependency caching
COPY memos/go.mod memos/go.sum* ./
# Download Go dependencies with BuildKit cache mount
RUN --mount=type=cache,target=/go/pkg/mod go mod download
# Copy all backend source code
COPY memos/ ./
# Copy built frontend assets from frontend stage
COPY --from=frontend /build/server/router/frontend/dist ./server/router/frontend/dist
# Build Go binary with CGO disabled, stripped symbols for smaller size
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o memos ./bin/memos/main.go

# Stage 3: Minimal runtime image
FROM alpine:3.19@${ALPINE_SHA}
# Install runtime dependencies and create non-root user in one layer
RUN apk --no-cache add ca-certificates wget && \
    addgroup -g 1000 memos && adduser -D -u 1000 -G memos memos && \
    mkdir -p /var/opt/memos && chown -R memos:memos /var/opt/memos
# Set working directory to binary location
WORKDIR /usr/local/bin
# Copy built Go binary from backend stage
COPY --from=backend /build/memos .
# Copy frontend assets from backend stage
COPY --from=backend /build/server/router/frontend/dist ./server/router/frontend/dist
# Switch to non-root user for security
USER memos
# Expose application port
EXPOSE 5230
# Set production environment variables
ENV MEMOS_MODE=prod MEMOS_PORT=5230
# Define volume mount point for persistent data (ECS handles actual mounting)
VOLUME /var/opt/memos
# Health check for container orchestration (ECS/Docker)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5230/ || exit 1
# Set application entrypoint
ENTRYPOINT ["./memos"]
