ARG BUILD_FROM=alpine:3.19

FROM $BUILD_FROM
ENV LANG C.UTF-8
WORKDIR /data

RUN apk update
RUN apk add i2c-tools
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
