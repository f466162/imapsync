FROM alpine

VOLUME /imapsync

RUN apk upgrade && \
    apk add imapsync shadow bash && \
    usermod -d /imapsync -s /bin/bash nobody && \
    chown nobody:nogroup /imapsync && \
    chmod u=rwx,g=rx,o= /imapsync && \
    apk del shadow && \
    rm -vrf /var/cache/apk/*

ADD imapsync.sh /usr/local/bin/imapsync.sh

USER nobody

ENTRYPOINT ["/usr/local/bin/imapsync.sh"]
