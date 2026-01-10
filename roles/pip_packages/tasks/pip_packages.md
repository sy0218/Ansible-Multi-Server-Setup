# 🐍 Python 패키지 설치 (Ansible)
- 지정된 Python 패키지를 **pip3로 설치**
- 설치 여부 검증
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# Install Python packages via pip
# -----------------------------------------------------
- name: "Install Python packages"
  pip:
    name: "{{ pip_packages.split(',') }}"
    state: present
    executable: pip3

# -----------------------------------------------------
# Verify Python packages installation
# -----------------------------------------------------
- name: "Check installed Python packages"
  shell: "pip3 show {{ item }}"
  loop: "{{ pip_packages.split(',') }}"
  register: pip_check
  changed_when: false
  ignore_errors: yes

- name: "Assert Python packages installed"
  assert:
    that:
      - pip_check.results | selectattr('rc','equalto',0) | list | length == (pip_packages.split(',') | length)
    success_msg: "Good!.. | Python packages installed successfully"
    fail_msg: "ERROR!.. | Some Python packages are missing"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Python 패키지 설치
- 쉼표(,)로 구분된 패키지를 pip3로 설치
- pip_packages 변수를 host.ini에 지정
---
### 2️⃣ 설치 검증
- pip3 show로 각 패키지 설치 여부 확인
- assert 모듈로 모든 패키지 설치 상태 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert Python packages installed]
ok: [apserver] => {
    "msg": "Good!.. | Python packages installed successfully"
}
~
```
---
