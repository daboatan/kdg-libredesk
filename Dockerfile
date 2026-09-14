FROM node:22-alpine AS frontend
WORKDIR /src/frontend
RUN corepack enable
COPY frontend/package.json frontend/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY frontend/ ./
RUN pnpm build:main && pnpm build:widget

FROM golang:1.25-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download && go install github.com/knadh/stuffbin/...
COPY . .
COPY --from=frontend /src/frontend/dist ./frontend/dist
RUN CGO_ENABLED=0 go build -o /out/libredesk ./cmd && \
    /go/bin/stuffbin -a stuff -in /out/libredesk -out /out/libredesk frontend/dist i18n schema.sql static

FROM alpine:3.18
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /libredesk
COPY --from=builder /out/libredesk ./libredesk
COPY --from=builder /src/config.sample.toml ./config.toml
