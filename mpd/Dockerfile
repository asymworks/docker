FROM alpine:3.12

RUN apk add mpd && setcap -r /usr/bin/mpd
RUN addgroup -g 101 media \
 && adduser -D -H -u 10001 -G media media \
 && adduser media users

VOLUME [ "/music", "/playlists", "/data" ]
EXPOSE 6600

ENTRYPOINT [ "mpd", "--no-daemon" ]
