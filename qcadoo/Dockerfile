# Qcadoo Dockerfile
# Copyright (c) Asymworks, LLC

# Global Arguments
ARG MES_VERSION=2.2.10

# Build Qcadoo
FROM maven:3.8-jdk-8 AS builder

RUN groupadd -g 7890 qcadoo \
    && useradd -u 7890 -g qcadoo -m qcadoo
WORKDIR /home/qcadoo
COPY build-qcadoo.sh /home/qcadoo/
ENV QCADOO_VERSION=$MES_VERSION
RUN /home/qcadoo/build-qcadoo.sh

# Deploy Container
FROM openjdk:8-jdk-slim

RUN groupadd -r -g 7890 qcadoo \
    && useradd -r -u 7890 -g qcadoo -d /srv/qcadoo -m qcadoo

COPY --from=builder /home/qcadoo/mes/mes-application/target/mes-application.zip /tmp/mes-application.zip
RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext postgresql-client unzip \
    && unzip -d /srv/qcadoo/ /tmp/mes-application.zip \
    && chown -R qcadoo:qcadoo /srv/qcadoo/mes-application \
    && chmod +x /srv/qcadoo/mes-application/bin/*.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080
USER qcadoo

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "start" ]
