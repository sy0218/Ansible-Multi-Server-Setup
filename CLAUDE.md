# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

An Ansible project that takes already-provisioned Ubuntu 22.04 hosts and standardizes them — OS hardening on every host, then optional layers for Docker, ZooKeeper, Kafka, NiFi, Spark, Hadoop, Hive, Elasticsearch, Kibana, Redis, PostgreSQL, Filebeat. One Control Node runs everything against N Managed Nodes over SSH.

Comments and task names throughout the codebase are in Korean; preserve that style when editing.

## Commands

```bash
# Install Ansible on the Control Node (one-time)
bin/ansible_setup.sh

# Run the full playbook. The argument is the absolute project root.
bin/start_ansible.sh /work/jsy/Ansible-Multi-Server-Setup

# Equivalent direct invocation
ansible-playbook -i host.ini ubuntu_ansible.yml -e 'ansible_remote_tmp=/tmp/.ansible_tmp'

# Target a single play / role group
ansible-playbook -i host.ini ubuntu_ansible.yml --tags <tag>     # if tags are added
ansible-playbook -i host.ini ubuntu_ansible.yml --limit s1       # one host
ansible-playbook -i host.ini ubuntu_ansible.yml --start-at-task "<task name>"

# Dry run / diff
ansible-playbook -i host.ini ubuntu_ansible.yml --check --diff

# Quick connectivity check
ansible -i host.ini Ubuntu_Servers -m ping
```

`start_ansible.sh` passes `ansible_remote_tmp=/tmp/.ansible_tmp`; that directory is created with sticky `1777` perms by `ansible_setup.sh` and is required for runs to succeed.

## Architecture

**One playbook, many plays, one role per concern.** [ubuntu_ansible.yml](ubuntu_ansible.yml) is a flat list of plays. Each play targets one inventory group (`Ubuntu_Servers`, `Docker_Servers`, `Kafka_Servers`, …) and applies a single matching role. Order matters: the `Ubuntu_Servers` play runs the full OS-hardening role chain first, then later plays layer services on top of subsets of those same hosts.

**Inventory is the configuration surface.** [host.ini](host.ini) is not just hosts — it defines every per-group variable the roles consume (`java_version`, `docker_data_root`, `kafka_url`, `redis_pass`, etc.). To enable a service on a host, add it to that service's `[*_Servers]` group; to retune behavior, edit the group's `:vars` block. There are no `group_vars/` or `host_vars/` directories — everything lives in `host.ini`.

**Role layout convention.** Every role under [roles/](roles/) is `roles/<name>/tasks/main.yml` plus a sibling `<name>.md` doc file (and `handlers/main.yml` where needed, e.g. [roles/docker/handlers/main.yml](roles/docker/handlers/main.yml)). There are no `defaults/`, `vars/`, or `templates/` directories — variables come from inventory, and file content is inlined via `copy: content: |` or `blockinfile`.

**Task pattern: do → assert.** Each role ends with an `assert:` block that re-checks the work (service active, package installed, key present, etc.) with `success_msg`/`fail_msg`. New tasks should follow this — the assert is the role's contract, not a nice-to-have.

**Cross-host coordination via `hostvars`.** [roles/ssh_keygen/tasks/main.yml](roles/ssh_keygen/tasks/main.yml) and [roles/etc_hosts/tasks/main.yml](roles/etc_hosts/tasks/main.yml) gather facts from every host in `groups['Ubuntu_Servers']` via `hostvars` to build `authorized_keys` and `/etc/hosts`. This is the established pattern for any role that needs to know about peers — don't reach for delegation or external state.

**Idempotency is a hard requirement.** Roles use `state: present`, `creates:`, `force: no`, `register` + `changed_when: false` for read-only checks, and `notify:` handlers for restarts. Maintain this when adding tasks; don't introduce shell commands that re-run destructively.

## Working with `ubuntu_ansible.yml`

The committed [ubuntu_ansible.yml](ubuntu_ansible.yml) frequently has most roles commented out — it's used as a "current run target" toggle, not the canonical full pipeline. The README's playbook section is the canonical full list of roles per play. When adding a new role, update both the README role list and the playbook, and add the corresponding `[*_Servers]` group + vars to `host.ini`.

## Secrets

`host.ini` contains plaintext SSH passwords, become passwords, root passwords, and DB passwords by design (lab/Vagrant environment). Don't restructure this into Ansible Vault unless the user asks — it would break `start_ansible.sh`'s no-prompt flow.
