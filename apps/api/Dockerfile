# Stage 1: Pruner - Generate minimal monorepo subset
FROM oven/bun:1.3.1 AS pruner
WORKDIR /app

RUN bun add -g turbo@2.6.1-canary.0 # TODO: update to latest version once the fix is released from canary branch
COPY . .
RUN turbo prune @bun-issue/api --docker

# Stage 2: Installer - Install dependencies
FROM oven/bun:1.3.1 AS installer
WORKDIR /app

# Copy pruned lockfile and package.json files
COPY --from=pruner /app/out/json/ .
COPY --from=pruner /app/out/bun.lock ./bun.lock

# Install dependencies (production only for final image)
RUN bun install --frozen-lockfile

# Stage 3: Builder - Build the application
FROM oven/bun:1.3.1 AS builder
WORKDIR /app

# Copy dependencies
COPY --from=installer /app/ .

# Copy source code
COPY --from=pruner /app/out/full/ .

# Build the restapi
RUN cd apps/api && bun run build

# Stage 4: Runner - Production image
FROM oven/bun:1.3.1-slim AS runner
WORKDIR /app

# Copy only production dependencies
COPY --from=installer /app/node_modules ./node_modules
COPY --from=installer /app/package.json ./package.json

# Copy built application
COPY --from=builder /app/apps/api/dist ./apps/api/dist
COPY --from=builder /app/apps/api/package.json ./apps/api/package.json

# Copy only necessary packages (if they're runtime dependencies)
COPY --from=builder /app/packages ./packages

WORKDIR /app/apps/api

ENV NODE_ENV=production

EXPOSE 3000

# Run the built output, not the source
CMD ["bun", "run", "dist/index.js"]