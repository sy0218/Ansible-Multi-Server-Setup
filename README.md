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
<br>

## 🧪 실행 방법
```bash
# 사전 검증
ansible-playbook -i host.ini ubuntu_ansible.yml

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
    ├── control/
    │   └── tasks/main.yml
    ├── packages/
    │   └── tasks/main.yml
    ├── nicname/
    │   └── tasks/main.yml
    ├── cloud_init/
    │   └── tasks/main.yml
    ├── ufw/
    │   └── tasks/main.yml
    └── locale_ko/
        └── tasks/main.yml
```
