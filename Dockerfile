# Stage 1: Pruner - Generate minimal monorepo subset
FROM oven/bun:latest AS pruner
WORKDIR /app

# Install turbo
RUN bun add -g turbo@latest

COPY . .

# Prune the monorepo to only include @bun-issue/api and its dependencies
RUN turbo prune @bun-issue/api --docker

# Stage 2: Installer - Install dependencies
FROM oven/bun:1.3.1 AS installer
WORKDIR /app

# Copy pruned monorepo
COPY --from=pruner /app/out/json .

# Install dependencies
RUN bun install

# Stage 3: Builder - Build the application
FROM oven/bun:1.3.1 AS builder
WORKDIR /app

# Copy installed dependencies
COPY --from=installer /app/node_modules node_modules
COPY --from=pruner /app/out/full .

# Build the restapi -> STOPS WORKING HERE
RUN cd apps/restapi && bun run build 

# # Stage 4: Runner - Production image
# FROM oven/bun:1.3.1 AS runner
# WORKDIR /app

# # Copy built application and dependencies
# COPY --from=builder /app/node_modules node_modules
# COPY --from=builder /app/apps/restapi apps/restapi
# COPY --from=builder /app/packages packages
# COPY --from=builder /app/package.json .

# WORKDIR /app/apps/restapi

# # Set environment
# ENV NODE_ENV=production

# # Expose port
# EXPOSE 3000

# # Run the application with Bun
# CMD ["bun", "run", "src/index.ts"]
