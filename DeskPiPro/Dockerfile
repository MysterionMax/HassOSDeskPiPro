ARG BUILD_FROM=alpine:3.19
FROM $BUILD_FROM

ENV LANG=C.UTF-8
WORKDIR /data

# 1. Install all dependencies required to build the C/Python drivers
RUN apk update && apk add --no-cache \
    i2c-tools \
    coreutils \
    g++ \
    make \
    gcc \
    git \
    bash

# 2. Clone the DeskPi hardware tools
RUN git clone https://github.com/DeskPi-Team/deskpi.git /data/deskpi

# 3. Enter the correct DeskPi Pro driver directory and build the binary ahead of time
WORKDIR /data/deskpi/drivers/c
RUN gcc -o deskpi-daemon deskpi.c

# 4. Define exactly what to execute when the add-on clicks "Start"
# We directly trigger the compiled daemon binary in the foreground
CMD ["/data/deskpi/drivers/c/deskpi-daemon"]