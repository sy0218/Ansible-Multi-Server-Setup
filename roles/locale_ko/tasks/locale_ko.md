# ⚙️ 시스템 Locale 한국어 설정 (Ansible)
- 시스템 기본 Locale을 ko_KR.UTF-8 로 설정한다.
- 한글 출력, 로그, 터미널 메시지 깨짐 현상을 방지한다.
- 서버 전역 Locale 설정으로 모든 사용자에게 동일하게 적용된다.
---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# Korean Locale 설정
# -----------------------------------------------------

# 1. Korean Language pack Install
- name: "Install Korean language package"
  apt:
    name: language-pack-ko
    state: present
    update_cache: yes

# 2. Make ko_KR.UTF-8 locale
- name: "Create ko_KR.UTF-8 locale"
  command: locale-gen ko_KR.UTF-8

# 3. Change system default language to Korean
- name: "Set default language to Korean"
  command: update-locale LANG=ko_KR.UTF-8

# 4. Use Korean right now
- name: "Apply Korean language now"
  shell: export LANG=ko_KR.UTF-8
  changed_when: false

# Korean Locale 검증
- name: "Assert.. system default locale is Korean"
  assert:
    that:
      - "'LANG=ko_KR.UTF-8' in lookup('file', '/etc/default/locale')"
    success_msg: "Good!.. | System default locale is set to Korean (ko_KR.UTF-8)"
    fail_msg: "ERROR!.. | System locale is NOT Korean"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 한국어 언어 패키지 설치
- language-pack-ko 패키지 설치
---
### 2️⃣ ko_KR.UTF-8 Locale 생성
- locale-gen 명령으로 UTF-8 기반 한국어 Locale 생성
- 시스템에서 해당 Locale 사용 가능 상태로 구성
---
### 3️⃣ 시스템 기본 Locale 변경
- /etc/default/locale 파일 기준
- 시스템 전역 기본 언어를 ko_KR.UTF-8 로 설정
---
### 4️⃣ 현재 세션에 즉시 적용
- export LANG=ko_KR.UTF-8 실행
- Ansible 실행 세션에서 즉시 반영
- 시스템 재부팅 없이도 확인 가능
### 
---
## 5️⃣ Locale 설정 검증
- /etc/default/locale 파일 기준으로 실제 설정 값 검증
- 단순 명령 성공 여부가 아닌 설정 결과 기준 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. system default locale is Korean]
ok: [192.168.56.60] => {
    "msg": "Good!.. | System default locale is set to Korean (ko_KR.UTF-8)"
}
~~
```
---
