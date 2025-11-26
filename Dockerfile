FROM elixir:1.19.3-alpine

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Phoenix
RUN mix archive.install hex phx_new 1.8.1 --force

# Set working directory
WORKDIR /app

# Copy mix files if they exist (for when project is already created)
# If mix.exs doesn't exist, this will be skipped during build
COPY mix.exs* mix.lock* ./

# Install dependencies if mix.exs exists
RUN if [ -f mix.exs ]; then mix deps.get; fi

# Copy application code
COPY . .

# Default command (will be overridden by docker-compose)
CMD ["sh"]
