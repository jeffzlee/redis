FROM alpine:latest

MAINTAINER Open Source Services [opensourceservices.fr]

RUN apk --update add \
    bash nano curl \
    redis && \
    rm -rf /var/cache/apk/*

RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu

RUN mkdir /data
RUN chown redis:redis /data

COPY src/ .
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR /data

EXPOSE 6379

VOLUME /data

CMD [ "redis-server" ]
