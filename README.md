# MIG ansible role

A simple ansible role to setup MIG aka Mozilla InvestiGator
http://mig.mozilla.org/

## Requirements & Dependencies

### Ansible
It was tested on the following versions:
 * 1.9

### Operating systems

Tested with vagrant only on Ubuntu 14.04 for now but should work on 12.04 and similar debian based systems.
Verified with kitchen against ubuntu14 and centos7

## Example Playbook

Just include this role in your list.
For example

```
- host: migserver
  roles:
    - Mayeu.RabbitMQ
    - mig

- host: migclient
  roles:
    - { role: mig, mig_mode: client, mig_api_host: ansiblemigservername }

```

Currently, I used a slightly modified version of Mayeu.RabbitMQ as normally, this role is expecting to have rabbitmq certificates available on orchestrator and I'm generating them on mig role if not existing.

Finish install by
0) check API is accessible
    $ curl http://localhost/api/v1/
    $ curl http://localhost/api/v1/dashboard | python -mjson.tool
(or https if enabled)
1) set gpg keys of investigators
2) validate w mig-console
3) run locally mig-agent or deploy it somewhere
$GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-agent-latest

As for any services, you are recommended to do hardening.
Especially on RabbitMQ part (include erlang epmd)

Some nrpe commands are included to help for monitoring.

## Variables

There is a good number of variables to set the different settings of MIG.
Some like password should be stored in ansible vault for production systems at least.

```
mig_user: "{{ ansible_ssh_user }}"
mig_gover: 1.5.2
mig_gopath: "/home/{{ mig_user }}/go"
mig_src: "{{ mig_gopath }}/src/mig.ninja/mig"
mig_api_port: 51664

mig_db_migadmin_pass: xxx
mig_db_migapi_pass: xxx
mig_db_migscheduler_pass: xxx

mig_rabbitmq_adminpass: xxx
mig_rabbitmq_schedpass: xxx
mig_rabbitmq_agentpass: xxx
mig_rabbitmq_workrpass: xxx

mig_rabbitmq_certinfo: '/C=US/ST=CA/L=San Francisco/O=MIG Ansible'
mig_rabbitmq_certduration: 1095
mig_rabbitmq_rsakeysize: 2048
mig_rabbitmq_cadir: "/home/{{ mig_user }}/ca"
mig_rabbitmq_cakey: "{{ mig_rabbitmq_cadir }}/ca.key"
mig_rabbitmq_cacertcrt: "{{ mig_rabbitmq_cadir }}/ca.crt"
#mig_rabbitmq_cacert: "{{ mig_rabbitmq_cadir }}/cacert.cert"
mig_rabbitmq_serverdir: "/home/{{ mig_user }}/server"
mig_rabbitmq_serverkey: "{{ mig_rabbitmq_serverdir }}/server-{{ ansible_hostname }}.key"
mig_rabbitmq_servercsr: "{{ mig_rabbitmq_serverdir }}/server-{{ ansible_hostname }}.csr"
mig_rabbitmq_servercrt: "{{ mig_rabbitmq_serverdir }}/server-{{ ansible_hostname }}.crt"
mig_rabbitmq_clientdir: "/home/{{ mig_user }}/client"

## To switch true, you need valid public signed certificate, not self-certificate
mig_nginx_use_ssl: false
mig_nginx_cert: /path/to/cert
mig_nginx_key: /path/to/key
```

## Continuous integration

you can test this role with test kitchen.
In the role folder, run
```
$ kitchen verify
```

Known bugs
* Ubuntu: the notify 'supervisor restart' fails the first time. not sure
  why. second time run is fine after you do ```sudo service supervisor restart; sudo service nginx restart```
  (failed notified handlers).
* centos: mig-scheduler fails to run because of postgresql permissions

## Troubleshooting & Known issues

* memory
Ensure you have enough memory and swap available

* ansible: go and rabbitmq not idempotent

* mig-scheduler not starting
```
$ $GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-scheduler 
Initializing Scheduler context...
FATAL: Init() -> initRelay() -> tls: oversized record received with length 20480
```
=
check ssl configuration is consistent on both scheduler and nginx/rabbitmq (fully disabled or enabled)

* pq: relation \"agents_stats\" does not exist
```
$ curl http://localhost/api/v1/dashboard
{"collection":{"version":"1.0","href":"http://localhost:51664/api/v1/dashboard","template":{},"error":{"code":"5505623982082","message":"Error while retrieving agent statistics: 'pq: relation \"agents_stats\" does not exist'"}}}
```
check that postgresql database is initialized

* no access to this vhost
```
$ $GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-scheduler 
Initializing Scheduler context...
FATAL: Init() -> initRelay() -> Exception (403) Reason: "no access to this vhost"
```
=
check rabbitmq available, configured and permissions applied on the right vhost
```
$ sudo -u rabbitmq rabbitmqctl status
$ sudo -u rabbitmq rabbitmqctl list_vhosts
$ sudo -u rabbitmq rabbitmqctl list_users
$ sudo -u rabbitmq rabbitmqctl list_permissions
$ tail /var/log/rabbitmq/rabbit*
```

* pq: role "migscheduler" does not exist
```
$ $GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-scheduler
Initializing Scheduler context...
FATAL: Init() -> initSecring() -> makeSecring() -> Error while retrieving scheduler private key: 'pq: role "migscheduler" does not exist'
```
=
check no typo in postgresql user name
```
$ sudo -u postgres psql
psql (9.3.10)
Type "help" for help.

postgres=# \du
                              List of roles
  Role name  |                   Attributes                   | Member of 
-------------+------------------------------------------------+-----------
 migadmin    |                                                | {}
 migapi      |                                                | {}
 migcheduler |                                                | {}
 postgres    | Superuser, Create role, Create DB, Replication | {}

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 mig       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres         +
           |          |          |             |             | postgres=CTc/postgres+
           |          |          |             |             | migadmin=CTc/postgres
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
```
*But what should be the (restricted) privileges of migapi and migscheduler?* (nothing in script)
Currently ALL

* 
/var/log/supervisor/mig-scheduler.log
```
Initializing Scheduler context...
FATAL: Init() -> initSecring() -> makeSecring() -> Error while retrieving scheduler private key: 'pq: Ident authentication failed for user "migscheduler"'
```
=
On Centos7, postgresql is returned with a migreadonly role
```
postgres=# \du
                                 List of roles
  Role name   |                   Attributes                   |   Member of
--------------+------------------------------------------------+---------------
 migadmin     |                                                | {}
 migapi       |                                                | {migreadonly}
 migreadonly  | Cannot login                                   | {}
 migscheduler |                                                | {migreadonly}
 postgres     | Superuser, Create role, Create DB, Replication | {}

postgres=# \l
                                    List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |     Access privileges
-----------+----------+----------+-------------+-------------+---------------------------
 mig       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres             +
           |          |          |             |             | postgres=CTc/postgres    +
           |          |          |             |             | migadmin=CTc/postgres    +
           |          |          |             |             | migapi=CTc/postgres      +
           |          |          |             |             | migscheduler=CTc/postgres
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres              +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres              +
           |          |          |             |             | postgres=CTc/postgres
```


## License

BSD 2-clause



