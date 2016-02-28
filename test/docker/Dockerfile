# Dockerfile inspired from https://hub.docker.com/r/williamyeh/ansible/

# ==> Choose a base image to emulate Linux distribution...
FROM williamyeh/ansible:ubuntu14.04-onbuild
#FROM williamyeh/ansible:ubuntu12.04-onbuild
#FROM williamyeh/ansible:debian8-onbuild
#FROM williamyeh/ansible:debian7-onbuild
#FROM williamyeh/ansible:centos7-onbuild
#FROM williamyeh/ansible:centos6-onbuild
#FROM williamyeh/ansible:alpine3-onbuild


# ==> Specify requirements filename;  default = "requirements.yml"
#ENV REQUIREMENTS  requirements.yml

# ==> Specify playbook filename;      default = "playbook.yml"
#ENV PLAYBOOK      playbook.yml

# ==> Specify inventory filename;     default = "/etc/ansible/hosts"
#ENV INVENTORY     inventory.ini

## add role and setting inventory
WORKDIR /tmp
## Docker doesn't allow to go outside of current context and we need to recover multiples roles...
#COPY ../.. /tmp
RUN echo localhost > /etc/ansible/hosts
RUN env DEBIAN_FRONTEND=noninteractive apt-get -y install git
RUN git clone https://github.com/juju4/ansible-roles.git roles

# ==> Executing Ansible (with a simple wrapper)...
RUN ansible-playbook-wrapper

