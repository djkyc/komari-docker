# syntax=docker/dockerfile:1

FROM alpine:3.21 AS downloader

ARG TARGETOS
ARG TARGETARCH
ARG KOMARI_VERSION=1.1.3

WORKDIR /tmp
RUN apk add --no-cache ca-certificates wget

# 下载 release 二进制：komari-linux-amd64 / komari-linux-arm64
RUN set -eux; \
    : "${TARGETOS:=linux}"; \
    case "${TARGETARCH}" in \
      amd64|arm64) ;; \
      *) echo "Unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    wget -O komari "https://github.com/komari-monitor/komari/releases/download/${KOMARI_VERSION}/komari-${TARGETOS}-${TARGETARCH}"; \
    chmod +x komari

FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app

COPY --from=downloader /tmp/komari /app/komari

# Komari 默认数据目录
VOLUME ["/app/data"]

# Komari 默认端口
EXPOSE 25774

# 常用默认环境变量（可按需覆盖）
ENV GIN_MODE=release \
    KOMARI_LISTEN=0.0.0.0:25774

ENTRYPOINT ["/app/komari", "server"]
