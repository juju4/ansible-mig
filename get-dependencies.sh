#!/bin/sh
## one script to be used by travis, jenkins, packer...

umask 022

rolesdir=$(dirname $0)/..

[ ! -d $rolesdir/redhat-epel ] && git clone https://github.com/juju4/ansible-redhat-epel $rolesdir/redhat-epel
[ ! -d $rolesdir/adduser ] && git clone https://github.com/juju4/ansible-adduser $rolesdir/adduser
[ ! -d $rolesdir/gpgkey_generate ] && git clone https://github.com/juju4/ansible-gpgkey_generate $rolesdir/gpgkey_generate
[ ! -d $rolesdir/playbook-rabbitmq ] && git clone https://github.com/juju4/ansible-playbook-rabbitmq $rolesdir/Mayeu.RabbitMQ
[ ! -d $rolesdir/mig-api ] && git clone https://github.com/juju4/ansible-mig-api $rolesdir/mig-api
[ ! -d $rolesdir/mig-scheduler ] && git clone https://github.com/juju4/ansible-mig-scheduler $rolesdir/mig-scheduler
[ ! -d $rolesdir/mig-postgres ] && git clone https://github.com/juju4/ansible-mig-postgres $rolesdir/mig-postgres
[ ! -d $rolesdir/mig-rabbitmq ] && git clone https://github.com/juju4/ansible-mig-rabbitmq $rolesdir/mig-rabbitmq
[ ! -d $rolesdir/mig-agentsbuild ] && git clone https://github.com/juju4/ansible-mig-agentsbuild $rolesdir/mig-agentsbuild

