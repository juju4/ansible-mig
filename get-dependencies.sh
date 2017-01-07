#!/bin/sh
## one script to be used by travis, jenkins, packer...

umask 022

if [ $# != 0 ]; then
rolesdir=$1
else
rolesdir=$(dirname $0)/..
fi

[ ! -d $rolesdir/juju4.redhat-epel ] && git clone https://github.com/juju4/ansible-redhat-epel $rolesdir/juju4.redhat-epel
[ ! -d $rolesdir/juju4.adduser ] && git clone https://github.com/juju4/ansible-adduser $rolesdir/juju4.adduser
[ ! -d $rolesdir/juju4.gpgkey_generate ] && git clone https://github.com/juju4/ansible-gpgkey_generate $rolesdir/juju4.gpgkey_generate
[ ! -d $rolesdir/playbook-rabbitmq ] && git clone https://github.com/juju4/ansible-playbook-rabbitmq $rolesdir/Mayeu.RabbitMQ
[ ! -d $rolesdir/juju4.golang ] && git clone https://github.com/juju4/ansible-golang $rolesdir/juju4.golang
[ ! -d $rolesdir/juju4.mig-api ] && git clone https://github.com/juju4/ansible-mig-api $rolesdir/juju4.mig-api
[ ! -d $rolesdir/juju4.mig-scheduler ] && git clone https://github.com/juju4/ansible-mig-scheduler $rolesdir/juju4.mig-scheduler
[ ! -d $rolesdir/juju4.mig-postgres ] && git clone https://github.com/juju4/ansible-mig-postgres $rolesdir/juju4.mig-postgres
[ ! -d $rolesdir/juju4.mig-rabbitmq ] && git clone https://github.com/juju4/ansible-mig-rabbitmq $rolesdir/juju4.mig-rabbitmq
[ ! -d $rolesdir/juju4.mig-agentsbuild ] && git clone https://github.com/juju4/ansible-mig-agentsbuild $rolesdir/juju4.mig-agentsbuild
## galaxy naming: kitchen fails to transfer symlink folder
#[ ! -e $rolesdir/juju4.mig ] && ln -s ansible-mig $rolesdir/juju4.mig
[ ! -e $rolesdir/juju4.mig ] && cp -R $rolesdir/ansible-mig $rolesdir/juju4.mig

## don't stop build on this script return code
true

