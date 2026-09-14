# ---- Build Stage ----
FROM golang:1.25-alpine AS builder

# Install build dependencies (git is often needed for go mod download)
RUN apk --no-cache add git

# Set the working directory inside the container
WORKDIR /src

# Copy the go module files first to leverage Docker layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the binary. 
# Note: The exact build command and output path depend on the project's Makefile.
# The developer docs indicate `make` builds a self-contained binary [citation:2].
# We use go build directly for a predictable output path.
RUN CGO_ENABLED=0 go build -o /out/libredesk ./cmd

# ---- Runtime Stage ----
FROM alpine:3.18

# Install necessary packages for runtime (CA certs for HTTPS, tzdata for timezones)
RUN apk --no-cache add ca-certificates tzdata

# Set the working directory to /libredesk
WORKDIR /libredesk

# Copy the compiled binary from the builder stage
COPY --from=builder /out/libredesk .

# Copy the sample config file (optional, but follows the original pattern)
COPY config.sample.toml config.toml

# Expose port 9000 for the application
EXPOSE 9000

# Set the default command to run the libredesk binary
CMD ["./libredesk"]