FROM golang:1.26-alpine AS build
RUN apk --update add ca-certificates
WORKDIR /app
COPY gatus/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gatus ./


FROM scratch
COPY --from=build /app/gatus .
COPY --from=build /app/config.yaml ./config/config.yaml
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
USER 1000:1000
EXPOSE 8080
ENTRYPOINT ["/gatus"]

