FROM ghcr.io/drop-oss/drop:latest

RUN apk add --no-cache jq blkid mount fuse ntfs-3g exfat-utils

COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]