# 🗂 logrotate 기본 설정
- 시스템 로그 파일의 회전 주기 및 보관 정책을 설정한다.
- 로그 파일 무한 증가로 인한 디스크 고갈을 방지하기 위한 설정이다.
---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# logrotate 기본 설정
# -----------------------------------------------------

# 1. 로그 회전 주기
- name: "Set logrotate rotation period to monthly"
  lineinfile:
    path: /etc/logrotate.conf
    regexp: '^(weekly|monthly|daily|yearly)$'
    line: 'weekly'
    state: present

# 2. 로그 보관 개수
- name: "Set logrotate rotate count to 12"
  lineinfile:
    path: /etc/logrotate.conf
    regexp: '^rotate\s+\d+'
    line: 'rotate 4'
    state: present

# 3. 로그 회전 후 새 파일 생성
- name: "Enable create option in logrotate"
  lineinfile:
    path: /etc/logrotate.conf
    regexp: '^create$'
    line: 'create'
    state: present

# 4. logrotate 실행 사용자 설정
- name: "Set logrotate su directive"
  lineinfile:
    path: /etc/logrotate.conf
    regexp: '^su\s+'
    line: 'su root adm'
    state: present

# 5. logrotate.d include 활성화
- name: "Enable include /etc/logrotate.d"
  lineinfile:
    path: /etc/logrotate.conf
    regexp: '^include\s+/etc/logrotate.d'
    line: 'include /etc/logrotate.d'
    state: present

# -----------------------------------------------------
# logrotate 설정 검증
# -----------------------------------------------------

- name: "Assert.. logrotate configuration is correctly set"
  assert:
    that:
      - "'weekly' in lookup('file', '/etc/logrotate.conf')"
      - "'rotate 4' in lookup('file', '/etc/logrotate.conf')"
      - "'create' in lookup('file', '/etc/logrotate.conf')"
      - "'su root adm' in lookup('file', '/etc/logrotate.conf')"
      - "'include /etc/logrotate.d' in lookup('file', '/etc/logrotate.conf')"
    success_msg: "Good!.. | logrotate configuration is correctly applied"
    fail_msg: "ERROR!.. | logrotate configuration is NOT correctly applied"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 로그 회전 주기 설정
- /etc/logrotate.conf 파일 수정
- 로그 회전 주기를 weekly 로 설정
---
### 2️⃣ 로그 보관 개수 설정
- 회전된 로그 파일을 4개까지 보관
- 오래된 로그는 자동 삭제
---
### 3️⃣ 로그 파일 생성 옵션
- 로그 회전 후 빈 로그 파일 자동 생성
- 서비스 재시작 없이 로그 기록 유지
---
### 4️⃣ logrotate 실행 권한 설정
- logrotate 작업을 root 사용자, adm 그룹 권한으로 수행
- 권한 문제로 인한 회전 실패 방지
---
### 5️⃣ 추가 설정 디렉토리 활성화
- /etc/logrotate.d 디렉토리 내 개별 로그 설정 포함
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. logrotate configuration is correctly set]
ok: [192.168.56.60] => {
    "msg": "Good!.. | logrotate configuration is correctly applied"
}
~
```
---
