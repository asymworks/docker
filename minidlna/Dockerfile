FROM alpine:3.12

RUN apk add --no-cache minidlna

EXPOSE 1900
EXPOSE 8200
VOLUME /var/cache/minidlna

ENTRYPOINT [ "/usr/sbin/minidlnad" ]
CMD [ "-S" ]
