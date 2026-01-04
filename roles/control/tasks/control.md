# 🖥 Control Node 기본 설정 (Ansible)

- Ansible **Control Node**에서  
password 기반 SSH 통신을 사용하기 위해 필요한 **sshpass 설치 및 검증** 작업을 수행한다.
---
<br>

## 🧩 구성 파일
- `main.yml`  
  - sshpass 설치
  - 설치 여부 검증
---
<br>

## 🛠 작업 내용
### 1️⃣ sshpass 설치

```yaml
- name: "Install sshpass on Control node"
  apt:
    name: sshpass
    state: present
    update_cache: yes
```
- apt 패키지 매니저를 사용하여 sshpass 설치
- 이미 설치되어 있을 경우 변경 없이 스킵 (멱등성 유지)
---
### 2️⃣ sshpass 설치 확인
```yaml
- name: "Check.. sshpass.."
  command: sshpass -V
  register: sshpass_check
  changed_when: false
```
- sshpass -V 명령어로 설치 여부 및 버전 확인
- 단순 검증 목적이므로 changed_when: false 설정
---
### 3️⃣ 설치 상태 출력
``` yaml
- name: "Status.. sshpass.."
  debug:
    msg: "Good!.. | {{ sshpass_check.stdout_lines[0] }} installed successfully.."
```
- sshpass 버전 정보를 포함한 성공 메시지 출력
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Status.. sshpass..]
ok: [control-node] => {
    "msg": "Good!.. | sshpass 1.09 installed successfully.."
}
```
