FROM alpine:3.12 as builder

ARG MYMPD_VERSION=6.9.1
RUN apk add --no-cache build-base cmake libid3tag-dev flac-dev openssl-dev linux-headers lua5.3-dev pkgconf mpd \
 && mkdir /src

WORKDIR /src
RUN wget https://github.com/jcorporation/myMPD/archive/v${MYMPD_VERSION}.tar.gz \
 && tar xzf v${MYMPD_VERSION}.tar.gz \
 && cd myMPD-${MYMPD_VERSION} \
 && mkdir release && cd release \
 && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=RELEASE .. \
 && make \
 && mkdir /app \
 && make DESTDIR=/app install

FROM alpine:3.12

RUN apk add --no-cache libid3tag flac openssl lua5.3 \
 && addgroup -S mympd \
 && adduser -S -D -H -h /var/lib/mympd -s /sbin/nologin -G mympd -g myMPD mympd

COPY --from=builder /app/usr/bin/* /usr/bin
COPY --from=builder /app/etc/mympd.conf /etc/mympd.conf

ENTRYPOINT [ "/usr/bin/mympd" ]
