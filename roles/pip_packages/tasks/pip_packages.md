# 🐍 Python 패키지 설치 (Ansible)
- `pip_packages` 변수 기반 Python 패키지 **pip3 설치**
- **사전 체크 → 누락분만 설치 → 사후 검증** 흐름으로 멱등성 보장
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 설치 전 Python 패키지 상태 확인 (멱등성 사전 체크)
# -----------------------------------------------------
- name: "Check pre-installed Python packages"
  shell: "pip3 show {{ item }}"
  loop: "{{ pip_packages.split(',') }}"
  register: pip_pre_check
  changed_when: false
  failed_when: false

# -----------------------------------------------------
# 설치 누락 패키지 목록 산출
# -----------------------------------------------------
- name: "Determine missing Python packages"
  set_fact:
    missing_pip_packages: "{{ pip_pre_check.results | selectattr('rc','ne',0) | map(attribute='item') | list }}"

# -----------------------------------------------------
# 누락된 패키지만 pip 설치 (이미 설치된 경우 skip)
# -----------------------------------------------------
- name: "Install missing Python packages"
  pip:
    name: "{{ missing_pip_packages }}"
    state: present
    executable: pip3
  when: missing_pip_packages | length > 0

# -----------------------------------------------------
# Python 패키지 설치 검증
# -----------------------------------------------------
- name: "Check installed Python packages"
  shell: "pip3 show {{ item }}"
  loop: "{{ pip_packages.split(',') }}"
  register: pip_check
  changed_when: false
  failed_when: false

- name: "Assert Python packages installed"
  assert:
    that:
      - item.rc == 0
    fail_msg: "[FAIL] Some Python packages are missing"
    success_msg: "Good!.. | Python packages installed successfully"
  loop: "{{ pip_check.results }}"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 사전 상태 확인
- `pip3 show`로 각 패키지 설치 여부 조회
- `changed_when: false`, `failed_when: false`로 결과만 수집 (실패해도 흐름 유지)
---
### 2️⃣ 누락 패키지 산출
- `selectattr('rc','ne',0)`로 미설치 패키지만 필터링
- `set_fact`에 `missing_pip_packages` 리스트로 저장
---
### 3️⃣ 누락분만 설치 (멱등성 핵심)
- `when: missing_pip_packages | length > 0` → 모두 설치돼 있으면 task 자체 skip
- 재실행 시 **changed=0** 보장
---
### 4️⃣ 설치 검증
- 설치 후 다시 `pip3 show`로 재확인
- `assert`를 항목별 loop로 수행해 **누락 패키지 식별 가능**
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Install missing Python packages]
skipping: [apserver]

TASK [Assert Python packages installed]
ok: [apserver] => (item={...'rc': 0, 'item': 'docker'...}) => {
    "msg": "Good!.. | Python packages installed successfully"
}
```
---