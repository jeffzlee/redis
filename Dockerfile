FROM alpine:latest

RUN apk --update add \
    bash nano curl \
    redis && \
    rm -rf /var/cache/apk/*

RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu

RUN mkdir /data
RUN chown redis:redis /data

COPY entrypoint.sh /opt/entrypoint.sh

RUN chmod +x /opt/entrypoint.sh
RUN sed -i -r 's/#*\s* protected-mode yes/protected-mode no/g' /etc/redis.conf
ENTRYPOINT ["/opt/entrypoint.sh"]

WORKDIR /data

EXPOSE 6379 

VOLUME /data

CMD [ "redis-server" , "/etc/redis.conf"]
