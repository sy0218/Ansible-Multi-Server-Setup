#!/usr/bin/bash

ANSIBLE_HOME="$1"
if [ -z "${ANSIBLE_HOME}" ]; then
    echo "[ERROR] ANSIBLE_HOME is empty"
    exit 1
fi

log() {
    echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - $1\n"
}

run_cmd() {
    log "[RUN] $1"
    eval "$1"
}

log "===== START ansible start ====="

log "ANSIBLE_HOME: ${ANSIBLE_HOME}"
run_cmd "ansible-playbook -i ${ANSIBLE_HOME}/host.ini ${ANSIBLE_HOME}/ubuntu_ansible.yml -e 'ansible_remote_tmp=/tmp/ansible_tmp'"

log "===== END ansible end ====="
