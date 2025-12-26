ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    bash \
    jq \
    curl

COPY rootfs /

RUN chmod a+x /run.sh
ENTRYPOINT ["/run.sh"]