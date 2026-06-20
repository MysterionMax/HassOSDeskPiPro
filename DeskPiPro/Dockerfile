ARG BUILD_FROM=alpine:3.19
FROM $BUILD_FROM

ENV LANG C.UTF-8
WORKDIR /data

# 1. Update system and install i2c-tools PLUS the compiler tools needed for the DeskPi driver
RUN apk update && apk add --no-cache \
    i2c-tools \
    coreutils \
    g++ \
    make \
    gcc \
    git

# 2. Clone the official DeskPi repository so the driver files actually exist
RUN git clone https://github.com/DeskPi-Team/deskpi.git /data/deskpi
RUN chmod +x /data/deskpi/install.sh

# 3. Copy your local run.sh script into the root directory
COPY run.sh /
RUN chmod a+x /run.sh

# 4. Let run.sh handle the startup
CMD [ "/run.sh" ]