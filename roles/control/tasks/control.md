# 🖥 Control Node 기본 설정 (Ansible)

- Ansible **Control Node**에서
  password 기반 SSH 통신을 위해 필요한 **sshpass 설치 및 검증** 작업을 수행한다.

---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# Control Node 기본 설정
# -----------------------------------------------------

# 1. sshpass 설치 여부 확인 (dpkg 기반 체크)
- name: "Check if sshpass is installed"
  command: dpkg -l | grep sshpass
  register: sshpass_installed
  changed_when: false
  failed_when: false

# 2. sshpass 설치 (없을 때만 실행)
- name: "Install sshpass on Control node"
  apt:
    name: sshpass
    state: present
    update_cache: yes
  when: sshpass_installed.rc != 0

# 3. sshpass 버전 확인
- name: "Verify sshpass version"
  command: sshpass -V
  register: sshpass_check
  changed_when: false

# 4. 설치 검증 (assert)
- name: "Verify sshpass installation"
  assert:
    that:
      - sshpass_check.rc == 0
    fail_msg: "[FAIL] sshpass install failed"
    success_msg: "[SUCCESS] sshpass install verified successfully {{ sshpass_check.stdout | default('no output') }}"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ sshpass 설치 여부 확인
- dpkg 기반으로 설치 여부 체크
- 없으면 rc != 0 반환
```bash
dpkg -l | grep sshpass
```
---
### 2️⃣ sshpass 설치 ( 조건부 )
- 설치가 안 되어 있을 때만 실행
- apt 패키지 설치 + cache 업데이트
```yaml
when: sshpass_installed.rc != 0
```
---
### 3️⃣ sshpass 버전 확인
- 설치 정상 여부 확인
``` bash
sshpass -V
```
---
### 4️⃣ assert 검증
- 설치 성공 여부 최종 검증
- 실패 시 playbook 즉시 중단
```yaml
assert:
  that:
    - sshpass_check.rc == 0
```

---
<br>

## ✅ 실행 결과 예시
```bash
[SUCCESS] sshpass install verified successfully sshpass 1.09
```
---
