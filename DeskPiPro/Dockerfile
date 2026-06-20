ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM $BUILD_FROM

ENV LANG=C.UTF-8

# Install dependencies
RUN apk update && apk add --no-cache \
    i2c-tools \
    jq \
    coreutils \
    bash

COPY run.sh /
RUN chmod a+x /run.sh

# Change the entrypoint behavior to run pure bash as PID 1 directly
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "/run.sh" ]