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
[Ubuntu_Servers]
192.168.56.60
192.168.56.61
192.168.56.62

[Ubuntu_Servers:vars]
ansible_user=vagrant
ansible_ssh_pass=vagrant
ansible_become=true
ansible_become_password=vagrant
root_password="1234"

install_packages=net-tools,python3-pip
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
    - packages
    - nicname
    - cloud_init
    - ufw
    - locale_ko
    - control
    - ntp
    - open_files
    - ssh_root_login
    - timezone
```
---
<br>

## 🧩 Roles 설명
### 🔹 control → [`📂 main.yml`](./roles/control/tasks/control.md)
- Control Node 기본 설정
- password 기반 SSH 사용을 위한 sshpass 설치
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
    └── java/
        └── tasks/main.yml
```
---
