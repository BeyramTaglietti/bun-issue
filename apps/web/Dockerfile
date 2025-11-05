# Stage 1: Pruner
FROM oven/bun:1.3.1 AS pruner
WORKDIR /app

RUN bun add -g turbo@2.6.1-canary.0
COPY . .
RUN turbo prune @bun-issue/web --docker

# Stage 2: Installer
FROM oven/bun:1.3.1 AS installer
WORKDIR /app

COPY --from=pruner /app/out/json/ .
COPY --from=pruner /app/out/bun.lock ./bun.lock

# Install dependencies - resolve conflicts in pruned lock file
RUN bun install --ignore-scripts

# Stage 3: Builder
FROM oven/bun:1.3.1 AS builder
WORKDIR /app

COPY --from=installer /app/ .
COPY --from=pruner /app/out/full/ .
RUN cd apps/web && bun run build
# Stage 4: Extract dist (just the output)
FROM scratch AS dist
COPY --from=builder /app/apps/web/dist /
