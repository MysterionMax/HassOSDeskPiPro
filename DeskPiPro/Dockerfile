ARG BUILD_FROM=alpine:3.19
FROM $BUILD_FROM

ENV LANG=C.UTF-8
WORKDIR /data

# 1. Update system and install required build components
RUN apk update && apk add --no-cache \
    i2c-tools \
    coreutils \
    g++ \
    make \
    gcc \
    git

# 2. Clone the repository into a clean workspace folder
RUN git clone https://github.com/DeskPi-Team/deskpi.git /data/deskpi

# 3. Automatically find and make ALL install scripts executable across the repo
RUN find /data/deskpi -name "install.sh" -exec chmod +x {} +

# 4. Copy your local execution script and specify container entryway
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]