# 🛠 multi-server-setup-ansible

다중 Ubuntu 서버를 대상으로  
**공통 시스템 설정을 Ansible로 자동화**하기 위한 프로젝트입니다.  
(Control Node 1대 + Managed Node 여러 대 구조)

---
<br>

## 📌 주요 특징
- 여러 대 Ubuntu 서버 일관된 환경 구성
- Role 기반 모듈화 설계
- 서버 초기 세팅 자동화
- 반복 실행 시에도 안전한 멱등성 구성

---
<br>

## 🧰 요구 사항
- OS: Ubuntu ( 우분투 )
- Control Node 1대
- Managed Node N대 (SSH 접근 가능)

---
<br>

## 🚀 Ansible 설치 (Control Node)
>⚠️ **Ansible은 Control Node에만 설치합니다.**
### 1️⃣ Ansible 설치
```bash
apt update
apt install -y ansible
```
### 2️⃣ 설치 확인
```bash
ansible --version
```
---
<br>

## 🖥 인벤토리 ( host.ini )
```bash
# -------------------------------------------------
# Ubuntu 공통 서버 그룹
# -------------------------------------------------
[Ubuntu_Servers]
ap   ansible_host=192.168.56.60
s1   ansible_host=192.168.56.61
s2   ansible_host=192.168.56.62

# -------------------------------------------------
# Ubuntu 공통 변수
# -------------------------------------------------
[Ubuntu_Servers:vars]
ansible_user=vagrant
ansible_ssh_pass=vagrant
ansible_become=true
ansible_become_password=vagrant
root_password="1234"

# 설치할 기본 패키지 목록
install_packages=net-tools,python3-pip

# 설치할 자바 버전
java_version=11

# job_project 환경 변수
job_project_envs=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64;KAFKA_HOME=/application/kafka;ZOOKEEPER_HOME=/application/zookeeper;HADOOP_HOME=/application/hadoop;HADOOP_COMMON_HOME=$HADOOP_HOME;HADOOP_MAPRED_HOME=$HADOOP_HOME;HADOOP_HDFS_HOME=$HADOOP_HOME;HADOOP_YARN_HOME=$HADOOP_HOME;HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop;HADOOP_LOG_DIR=/logs/hadoop;HADOOP_PID_DIR=/var/run/hadoop/hdfs;HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native;HADOOP_OPTS=-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR;HIVE_HOME=/application/hive;HIVE_AUX_JARS_PATH=$HIVE_HOME/aux;PATH=$JAVA_HOME/bin:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$HIVE_AUX_JARS_PATH/bin:$KAFKA_HOME/bin:$ZOOKEEPER_HOME/bin:$PATH


# -------------------------------------------------
# Docker 서버 그룹
# ------------------------------------------------
[Docker_Servers]
ap
s1
s2

# -------------------------------------------------
# Docker 전용 변수
# -------------------------------------------------
[Docker_Servers:vars]
docker_data_root=/docker


# -------------------------------------------------
# Zookeeper_Servers 서버 그룹
# -------------------------------------------------
[Zookeeper_Servers]
ap zookeeper_myid=1
s1 zookeeper_myid=2
s2 zookeeper_myid=3

# -------------------------------------------------
# ZooKeeper 공통 변수
# -------------------------------------------------
[Zookeeper_Servers:vars]
zookeeper_install_dir=/application
zookeeper_data_dir=/application/id_zookeeper
zookeeper_url=https://archive.apache.org/dist/zookeeper/zookeeper-3.7.2/apache-zookeeper-3.7.2-bin.tar.gz


# -------------------------------------------------
# Kafka 서버 그룹
# -------------------------------------------------
[Kafka_Servers]
ap
s1
s2

# -------------------------------------------------
# Kafka 공통 변수
# -------------------------------------------------
[Kafka_Servers:vars]
kafka_install_dir=/application
kafka_log_dir=/logs/kafka_log
kafka_url=https://archive.apache.org/dist/kafka/3.6.2/kafka_2.13-3.6.2.tgz
```
---
<br>

## ▶️ 플레이북 (ubuntu_ansible.yml)
```yaml
---
# =====================================================
# Control Node
# =====================================================
- name: "[ Setup Control Node.. ]"
  hosts: localhost
  become: true
  gather_facts: false

  roles:
    - control

# =====================================================
# Ubuntu Servers
# =====================================================
- name: "[ Ubuntu_Servers Settings.. ]"
  hosts: Ubuntu_Servers
  become: true
  gather_facts: false

  vars:
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"

  roles:
    - root_password
    - packages
    - nicname
    - cloud_init
    - ufw
    - locale_ko
    - ssh_root_login
    - timezone
    - ntp
    - open_files
    - logrotate
    - shell_default
    - java
    - package_version_lock
    - package_update_lock
    - bash_common
    - ssh_keygen
    - etc_hosts

# =====================================================
# Docker Servers
# =====================================================
- name: "[ Docker_Servers Settings.. ]"
  hosts: Docker_Servers
  become: true
  gather_facts: true

  vars:
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"

  roles:
    - docker

# =====================================================
# Zookeeper Servers
# =====================================================
- name: "[ Zookeeper_Servers Settings.. ]"
  hosts: Zookeeper_Servers
  become: true
  gather_facts: false

  vars:
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"

  roles:
    - zookeeper

# =====================================================
# Kafka Servers
# =====================================================
- name: "[ Kafka_Servers Settings.. ]"
  hosts: Kafka_Servers
  become: true
  gather_facts: false

  vars:
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"

  roles:
    - kafka
```
---
<br>

## 🧩 Roles 설명
### 🔹 control → [`📂 main.yml`](./roles/control/tasks/control.md)
- Control Node 기본 설정
- password 기반 SSH 사용을 위한 sshpass 설치
---
### 🔹 root_password → [`📂 main.yml`](./roles/root_password/tasks/root_password.md)
- root 계정 패스워드 설정
---
### 🔹 packages → [`📂 main.yml`](./roles/packages/tasks/packages.md)
- 공통 필수 패키지 설치
- install_packages 변수 기반 동적 설치
---
### 🔹 nicname → [`📂 main.yml`](./roles/nicname/tasks/nicname.md)
- 네트워크 인터페이스 이름 통일
---
### 🔹 cloud_init → [`📂 main.yml`](./roles/cloud_init/tasks/cloud_init.md)
- cloud-init 비활성화
---
### 🔹 ufw → [`📂 main.yml`](./roles/ufw/tasks/ufw.md)
- 방화벽(UFW) 비활성화
---
### 🔹 locale_ko → [`📂 main.yml`](./roles/locale_ko/tasks/locale_ko.md)
- 시스템 Locale 한국어 설정
- UTF-8 환경 구성
---
### 🔹 ssh_root_login → [`📂 main.yml`](./roles/ssh_root_login/tasks/ssh_root_login.md)
- SSH root 계정 로그인 허용 설정
---
### 🔹 timezone → [`📂 main.yml`](./roles/timezone/tasks/timezone.md)
- 시스템 Time Zone 설정
- `Asia/Seoul` 기준 시간 적용
---
### 🔹 ntp → [`📂 main.yml`](./roles/ntp/tasks/ntp.md)
- NTP 서버 설정
- systemd-timesyncd 기반 시간 동기화
---
### 🔹 open_files → [`📂 main.yml`](./roles/open_files/tasks/open_files.md)
- root 계정 open files(nofile) 제한 증가
- `/etc/security/limits.conf` 기반 설정
---
### 🔹 logrotate → [`📂 main.yml`](./roles/logrotate/tasks/logrotate.md)
- 시스템 로그 회전 정책 설정
---
### 🔹 shell_default → [`📂 main.yml`](./roles/shell_default/tasks/shell_default.md)
- 시스템 기본 `/bin/sh` 설정 변경
- dash 비활성화 및 bash 기본 shell 적용
---
### 🔹 java → [`📂 main.yml`](./roles/java/tasks/java.md)
- host.ini 변수 기반 Java 버전 선택 설치
- OpenJDK 8 / 11 / 17 / 21 유연한 적용
---
### 🔹 package_version_lock → [`📂 main.yml`](./roles/package_version_lock/tasks/package_version_lock.md)
- 커널(Kernel) 및 Java 패키지 버전 고정
---
### 🔹 package_update_lock → [`📂 main.yml`](./roles/package_update_lock/tasks/package_update_lock.md)
- APT 패키지 자동 업데이트 비활성화
- unattended-upgrades 및 주기적 패키지 업데이트 차단
---
### 🔹 common_bash → [`📂 main.yml`](./roles/bash_common/tasks/bash_common.md)
- 시스템 공통 Bash 환경 설정 적용
- `/etc/job_project.conf` 기반 환경 통합 관리
- rm / cp / mv 보호 alias 및 PS1 프롬프트 통일
---
### 🔹 ssh_keygen → [`📂 main.yml`](./roles/ssh_keygen/tasks/ssh_keygen.md)
- SSH 무비밀번호 접속 구성 및 검증
- 모든 서버에서 SSH Key 자동 생성
- 모든 서버 간 공개키 상호 공유
---
### 🔹 etc_hosts → [`📂 main.yml`](./roles/etc_hosts/tasks/etc_hosts.md)
- 인벤토리 기반 `/etc/hosts` 파일 자동 생성
---
### 🔹 docker → [`📂 main.yml`](./roles/docker/tasks/docker.md)
- Docker Engine 공식 저장소 기반 설치
---
### 🔹 zookeeper → [`📂 main.yml`](./roles/zookeeper/tasks/zookeeper.md)
- ZooKeeper 설치
---
### 🔹 kafka → [`📂 main.yml`](./roles/kafka/tasks/kafka.md)
- Kafka 설치
---
<br>

## 🧪 실행 방법
```bash
# 사전 검증
ansible-playbook -i host.ini ubuntu_ansible.yml --check

# 실행
ansible-playbook -i host.ini ubuntu_ansible.yml
```
---
<br>

## 📁 디렉토리 구성도
```bash
multi-server-setup-ansible/
├── host.ini
├── ubuntu_ansible.yml
└── roles/
    ├── root_password/
    │   └── tasks/main.yml
    ├── cloud_init/
    │   └── tasks/main.yml
    ├── control/
    │   └── tasks/main.yml
    ├── locale_ko/
    │   └── tasks/main.yml
    ├── nicname/
    │   ├── handlers/main.yml
    │   └── tasks/main.yml
    ├── ntp/
    │   └── tasks/main.yml
    ├── open_files/
    │   └── tasks/main.yml
    ├── packages/
    │   └── tasks/main.yml
    ├── ssh_root_login/
    │   ├── handlers/main.yml
    │   └── tasks/main.yml
    ├── timezone/
    │   └── tasks/main.yml
    ├── ufw/
    │   └── tasks/main.yml
    ├── logrotate/
    │   └── tasks/main.yml
    ├── shell_default/
    │   └── tasks/main.yml
    ├── java/
    │   └── tasks/main.yml
    ├── bash_common/
    │   └── tasks/main.yml
    ├── package_version_lock/
    │   └── tasks/main.yml
    ├── package_update_lock/
    │   └── tasks/main.yml
    ├── ssh_keygen/
    │   └── tasks/main.yml
    ├── etc_hosts/
    │   └── tasks/main.yml
    ├── docker/
    │   ├── handlers/main.yml
    │   └── tasks/main.yml
    ├── zookeeper/
    │   └── tasks/main.yml
    └── kafka/
         └── tasks/main.yml
```
---
