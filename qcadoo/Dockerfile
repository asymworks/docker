# Qcadoo Dockerfile
# Copyright (c) Asymworks, LLC

# Global Arguments
ARG MES_UID=7890
ARG MES_GID=7890
ARG MES_VERSION=2.2.10

# Build Qcadoo
FROM maven:3.8-jdk-8 AS builder

RUN groupadd -g ${MES_GID} qcadoo \
    && useradd -u ${MES_UID} -g qcadoo -m qcadoo
WORKDIR /home/qcadoo
COPY build-qcadoo.sh /home/qcadoo/
RUN /home/qcadoo/build-qcadoo.sh

# Deploy Container
FROM openjdk:8-jdk-slim

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && groupadd -r -g ${MES_GID} qcadoo \
    && useradd -r -u ${MES_UID} -g qcadoo -d /srv/qcadoo -m qcadoo

COPY --from=builder /home/qcadoo/mes/mes-application/target/mes-application.zip /tmp/mes-application.zip
RUN unzip -d /srv/qcadoo/ /tmp/mes-application.zip \
    && chown -R qcadoo:qcadoo /srv/qcadoo/mes-application \
    && chmod +x /srv/qcadoo/mes-application/bin/*.sh

EXPOSE 8080
USER qcadoo

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "start" ]