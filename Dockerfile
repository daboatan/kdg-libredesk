# ---------- Builder stage ----------
FROM golang:1.25-alpine AS builder

RUN apk --no-cache add git
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -o /out/libredesk ./cmd

# ---------- Runtime stage ----------
FROM alpine:3.18

RUN apk --no-cache add ca-certificates tzdata
WORKDIR /libredesk

COPY --from=builder /out/libredesk .
COPY --from=builder /src/config.sample.toml config.toml

# 👇 Add these lines to include runtime assets
COPY --from=builder /src/i18n ./i18n
COPY --from=builder /src/static ./static
COPY --from=builder /src/schema.sql ./schema.sql