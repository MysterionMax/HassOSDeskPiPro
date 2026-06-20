ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM $BUILD_FROM

ENV LANG=C.UTF-8

# Install only the system packages your run.sh script actually calls
RUN apk update && apk add --no-cache \
    i2c-tools \
    jq \
    coreutils

# Copy your local run.sh script into the container root context
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]