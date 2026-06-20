ARG BUILD_FROM=alpine:3.19
FROM $BUILD_FROM

ENV LANG=C.UTF-8
WORKDIR /data

# 1. Update system and install tools
RUN apk update && apk add --no-cache \
    i2c-tools \
    coreutils \
    g++ \
    make \
    gcc \
    git

# 2. Clone the repository
RUN git clone https://github.com/DeskPi-Team/deskpi.git /data/deskpi

# 3. Target the correct subfolder for DeskPi Pro compilation files
WORKDIR /data/deskpi/drivers/c
RUN chmod +x install.sh

# 4. Bring your local run.sh script back to the main data folder and set entry point
WORKDIR /
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]