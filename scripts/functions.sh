#!/usr/bin/bash

# ----------------------------------------
# INFO 로그
# ----------------------------------------
log_info() {
    echo "[INFO ] [$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# ----------------------------------------
# ERROR 로그
# ----------------------------------------
log_error() {
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

# ----------------------------------------
# kafka control 함수
# ----------------------------------------
kafka_ctl() {
    local IP="$1"
    local OPT="$2"
    local KAFKA_BIN="${KAFKA_HOME}/bin"
    local KAFKA_CONF="${KAFKA_HOME}/config/server.properties"

    case "${OPT}" in
        start)
            log_info "[Kafka] ${IP} START"
            ssh "${IP}" "${KAFKA_BIN}/kafka-server-start.sh -daemon ${KAFKA_CONF}"
            log_info "[kafka] ${IP} STARTED"
            ;;
        stop)
            log_info "[Kafka] ${IP} STOP"
            ssh "${IP}" "${KAFKA_BIN}/kafka-server-stop.sh"
            log_info "[kafka] ${IP} STOPPED"
            ;;
        status)
            # 원격 서버에서 Kafka 프로세스 체크, 바로 조건문으로 처리
            log_info "[Kafka] ${IP} STATUS"
            if ssh "${IP}" "ps -ef | grep -i 'kafka.Kafka' | grep -v grep" &>/dev/null; then
                log_info "[Kafka] ${IP} is RUNNING..!!"
            else
                log_error "[Kafka] ${IP} is NOT RUNNING..!!"
            fi
            ;;
    esac
}
