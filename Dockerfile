FROM alpine


# 036A9C25BF357DD4 - Tianon Gravi <tianon@tianon.xyz>
#   http://pgp.mit.edu/pks/lookup?op=vindex&search=0x036A9C25BF357DD4
ENV GOSU_VERSION="1.7" \
	GOSU_DOWNLOAD_URL="https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64" \
	GOSU_DOWNLOAD_SIG="https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64.asc" \
	GOSU_DOWNLOAD_KEY="0x036A9C25BF357DD4"

# Download and install gosu
#   https://github.com/tianon/gosu/releases
RUN buildDeps='curl gnupg' HOME='/root' \
	&& set -x \
	&& apk add --update $buildDeps \
	&& gpg-agent --daemon \
	&& gpg --keyserver pgp.mit.edu --recv-keys $GOSU_DOWNLOAD_KEY \
	&& echo "trusted-key $GOSU_DOWNLOAD_KEY" >> /root/.gnupg/gpg.conf \
	&& curl -sSL "$GOSU_DOWNLOAD_URL" > gosu-amd64 \
	&& curl -sSL "$GOSU_DOWNLOAD_SIG" > gosu-amd64.asc \
	&& gpg --verify gosu-amd64.asc \
	&& rm -f gosu-amd64.asc \
	&& mv gosu-amd64 /usr/bin/gosu \
	&& chmod +x /usr/bin/gosu \
	&& apk del --purge $buildDeps \
	&& rm -rf /root/.gnupg \
	&& rm -rf /var/cache/apk/* \
;
FROM mendsley/alpine-gosu MAINTAINER Matthew Endsley <mendsley@gmail.com> # add our user/group first to ensure my get consistent ids RUN addgroup redis \
	&& adduser -H -D -s /bin/false -G redis redis
# Patches for Alpine compatibility \ ENV REDIS_VERSION="3.2.9" \ REDIS_DOWNLOAD_URL="http://download.redis.io/releases/redis-3.2.9.tar.gz" \ REDIS_DOWNLOAD_SHA1="8fad759f28bcb14b94254124d824f1f3ed7b6aa6" # Download and build redis RUN buildDeps='curl tar patch make gcc musl-dev linux-headers' \
	&& set -x \
	&& apk add --update $buildDeps \
	&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
	&& echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
	&& mkdir -p /usr/src/redis \
	&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& rm -f redis.tar.gz \
	&& cd /usr/src/redis \
	&& make \
	&& make install \
	&& cd / \
	&& rm -rf /usr/src \
	&& apk del $buildDeps \
	&& rm -rf /var/cache/apk/* \
	;
RUN mkdir /data \
	&& chown redis:redis /data \
	;
VOLUME /data
WORKDIR /data
COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 6379 CMD ["redis-server"]
