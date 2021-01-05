FROM python:3.9-slim

RUN apt-get update && apt-get upgrade -y \
    && apt-get -y install --no-install-recommends build-essential libffi-dev openssh-client sshpass \
    && pip install pip --upgrade \
    && pip install ansible==2.10.4 \
    && useradd -g users -m ansible

RUN pip install ansible-lint

USER ansible
WORKDIR /home/ansible
RUN mkdir .ssh && echo "UserKnownHostsFile /ansible/known_hosts" > .ssh/config
