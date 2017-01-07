[![Build Status](https://travis-ci.org/juju4/ansible-mig.svg?branch=master)](https://travis-ci.org/juju4/ansible-mig)

# MIG ansible role

Ansible role to setup MIG aka Mozilla InvestiGator
http://mig.mozilla.org/

This role is just a master for a single-server setup or to show how to setup multi-node setup (Vagrantfile.multi)

## Requirements & Dependencies

### Ansible
It was tested on the following versions:
 * 2.0

### Operating systems

Verified with kitchen against ubuntu trusty, xenial and centos7

## Example Playbook

Just include this role in your list.
For example

```
- hosts: migserver
  roles:
    - Mayeu.RabbitMQ
    - mig

- hosts: migclient
  roles:
    - { role: mig, mig_mode: client, mig_api_host: ansiblemigservername }
# OR
- hosts: migclient2
  roles:
    - { role: migclient, mig_api_host: ansiblemigservername }

```

Currently, I used a slightly modified version of Mayeu.RabbitMQ as normally, this role is expecting to have rabbitmq certificates available on orchestrator and I'm generating them on mig role if not existing.

You should have your investigator gpg keys (fingerprint, pubkey) ready before executing this role or use gpgkey_generate role to do so..

It is advised to use separate role migclient for client install as mig role as a role dependency to RabbitMQ and it does not seem possible to have it conditional currently. (https://groups.google.com/forum/#!msg/ansible-devel/NsgcczA8czs/fwjrNJB5a4QJ)

Finish install by
0) check API is accessible
```
    $ curl http://localhost/api/v1/
    $ curl http://localhost/api/v1/dashboard | python -mjson.tool
```
(or https if enabled)
1) validate w mig-console (need to set ~/.migrc, template provided)
```
$ sudo cp -R .gnupg /home/mig/; sudo chown -R mig /home/mig/.gnupg
$ sudo -u mig -H -s
$ $HOME/go/src/mig.ninja/mig/bin/linux/amd64/mig-console
```
2) run locally mig-agent or deploy it somewhere
```
$GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-agent-latest
```
if server is withagent enabled, mig-agent should already be running
```
$ pgrep mig-agent
```
As for any services, you are recommended to do hardening.
Especially on RabbitMQ part (include erlang epmd)

Some nrpe commands are included to help for monitoring.

Post-install, check your migrc and run mig-console (as mig user)
```
$ cat ~/.migrc
$ $HOME/go/src/mig.ninja/mig/bin/linux/amd64/mig-console
```

## Variables

There is a good number of variables to set the different settings of MIG. Both API and RabbitMQ hosts should be accessible to clients.
Some like password should be stored in ansible vault for production systems at least.

See relevant roles or examples from kitchen default.yml or vagrant site-mig.yml

## Continuous integration

This role has a travis basic test (for github), more advanced with kitchen and also a Vagrantfile (test/vagrant).
Default kitchen config (.kitchen.yml) is lxd-based, while (.kitchen.vagrant.yml) is vagrant/virtualbox based.

Once you ensured all necessary roles are present, You can test with:
```
$ gem install kitchen-ansible kitchen-lxd_cli kitchen-sync kitchen-vagrant
$ cd /path/to/roles/myrole
$ kitchen verify
$ kitchen login
$ KITCHEN_YAML=".kitchen.vagrant.yml" kitchen verify
```
or
```
$ cd /path/to/roles/myrole/test/vagrant
$ ln -s Vagrantfile.multi Vagrantfile
$ vagrant up
$ vagrant ssh vrabbit
$ vagrant ssh vapi
vagrant@vapi:~$ sudo -H -u _mig mig-console
$ vagrant ssh vclient
```

Role has also a packer config which allows to create image for virtualbox, vmware, eventually digitalocean, lxc and others.
When building it, it's advise to do it outside of roles directory as all the directory is upload to the box during building 
and it's currently not possible to exclude packer directory from it (https://github.com/mitchellh/packer/issues/1811)
```
$ cd /path/to/packer-build
$ cp -Rd /path/to/myrole/packer .
## update packer-*.json with your current absolute ansible role path for the main role
## you can add additional role dependencies inside setup-roles.sh
$ cd packer
$ packer build packer-*.json
$ packer build -only=virtualbox-iso packer-*.json
## if you want to enable extra log
$ PACKER_LOG_PATH="packerlog.txt" PACKER_LOG=1 packer build packer-*.json
## for digitalocean build, you need to export TOKEN in environment.
##  update json config on your setup and region.
$ export DO_TOKEN=xxx
$ packer build -only=digitalocean packer-*.json
```


## Troubleshooting & Known issues

* memory
Ensure you have enough memory and swap available. On vagrant 512M+swap or 1024M seems to be fine.

* Vagrant up fails on network
If using xenial image, you need vagrant >= 1.8.4 to support new network interface naming.
https://github.com/mitchellh/vagrant/issues/6871

* Multi-tier test setup
kitchen can't test multi-note setup currently so Vagrantfile with serverspec is used.
https://github.com/test-kitchen/test-kitchen/issues/873
Currently, it can load 6 hosts: postgres, rabbitmq, api, scheduler, agent build and a client
Issue with client connecting to rabbitmq
```
$ cat /var/log/supervisor/mig-agent.log
[info] Failed to connect to relay directly: 'initMQ() -> Exception (501) Reason: "read tcp 192.168.101.101:51766->192.168.101.51:5671: read: connection reset by peer"'
```
but mig-scheduler seems connected correctly.
= check rabbitmq port is consistent between all hosts
  still happen on ssl setup?

```
$ cat /var/log/supervisor/mig-scheduler.log
FATAL: Init() -> initRelay() -> x509: cannot validate certificate for 192.168.101.51 because it doesn't contain any IP SANs
```
= set subjectAltName (SAN) with IP address in rabbitmq-openssl.cnf


## License

BSD 2-clause



