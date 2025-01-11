# Shared base stage with core tools
FROM golang:1.22-bullseye as base
WORKDIR /app
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

# Install sqitch and postgres client
RUN apt-get update && apt-get install -y \
    sqitch \
    postgresql-client \
    libdbd-pg-perl \
    && rm -rf /var/lib/apt/lists/*

# Module download stage
FROM base AS modules
COPY go.mod go.sum ./
RUN go mod download

# Development stage
FROM modules as dev
RUN go install github.com/cosmtrek/air@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install github.com/sqlc-dev/sqlc@latest

COPY .air.toml ./
CMD ["air", "-c", ".air.toml"]

# Builder stage
FROM modules as builder
COPY . .
RUN go build -buildvcs=false -o /bin/app

# Production stage
FROM gcr.io/distroless/static:nonroot as prod
COPY --from=builder /bin/app /app
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/app"]
CMD []