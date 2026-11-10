FROM golang:1.27.3-trixie AS builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
# CGO off: one self-contained file that doesn't need the OS's C library, so it runs on a minimal base image
RUN CGO_ENABLED=0 go build -o /dashboard .


# distroless: no shell or package manager, just enough to run a static binary
FROM gcr.io/distroless/static-debian13:nonroot

COPY --from=builder /dashboard /usr/local/bin/dashboard

USER 10001:10001
EXPOSE 8081

CMD ["dashboard"]
