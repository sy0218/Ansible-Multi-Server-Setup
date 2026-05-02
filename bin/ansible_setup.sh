#!/usr/bin/bash

set -e # 에러나면 바로 종료

log() {
    echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - $1\n"
}

run_cmd() {
    log "[RUN] $1"
    eval "$1"
}

log "===== START ansible setup ====="

run_cmd "apt update"
run_cmd "apt install -y vim"
run_cmd "ansible --version"

log "===== END ansible setup ====="
