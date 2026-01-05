# 🐚 시스템 기본 Shell 변경 (dash → bash)

- 시스템 기본 `/bin/sh`를 dash가 아닌 bash로 변경한다.
- dash로 인한 스크립트 호환성 문제를 방지하기 위한 설정이다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# 시스템 기본 shell 변경 (dash → bash)
# -----------------------------------------------------

- name: "Disable dash as default /bin/sh"
  debconf:
    name: dash
    question: dash/sh
    value: false
    vtype: boolean

- name: "Reconfigure dash package"
  command: dpkg-reconfigure -f noninteractive dash
  changed_when: false

# -----------------------------------------------------
# 시스템 기본 shell 변경 검증
# -----------------------------------------------------

- name: "Assert.. default /bin/sh points to bash"
  assert:
    that:
      - "lookup('pipe', 'readlink -f /bin/sh') == '/usr/bin/bash'"
    success_msg: "Good!.. | Default shell (/bin/sh) is set to bash"
    fail_msg: "ERROR!.. | Default shell (/bin/sh) is NOT set to bash"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ dash 기본 shell 비활성화
- debconf 를 사용하여 dash 패키지 설정 변경
- /bin/sh가 dash를 가리키지 않도록 설정
---
### 2️⃣ dash 패키지 재구성
- non-interactive 방식으로 dpkg-reconfigure 실행
- 자동화 환경에서도 입력 대기 없이 적용 가능
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. default /bin/sh points to bash]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Default shell (/bin/sh) is set to bash"
}
~
```
---
