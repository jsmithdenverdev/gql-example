# Shared base stage with core tools
FROM golang:1.23.4-bullseye as base
WORKDIR /app
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=arm64

# Module download stage
FROM base AS modules
COPY go.mod go.sum ./
RUN go mod download

# Development stage
FROM modules as dev
RUN go install github.com/air-verse/air@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest

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