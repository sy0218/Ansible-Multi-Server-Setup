# ☕ Java 설치 (변수 기반)

- host.ini 변수 기반으로 Java 버전을 선택하여 설치한다.
- 서버 환경에 따라 Java 8 / 11 / 17 / 21 등 유연하게 적용 가능하다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# Java 설치 (변수 기반)
# -----------------------------------------------------

- name: "Update apt cache"
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: "Install OpenJDK (version {{ java_version }})"
  apt:
    name: "openjdk-{{ java_version }}-jdk"
    state: present

# -----------------------------------------------------
# Java 설치 검증
# -----------------------------------------------------

- name: "Assert.. Java {{ java_version }} is installed"
  assert:
    that:
      - "'openjdk' in lookup('pipe', 'java -version 2>&1')"
      - "'{{ java_version }}' in lookup('pipe', 'java -version 2>&1')"
    success_msg: "Good!.. | Java {{ java_version }} installed successfully"
    fail_msg: "ERROR!.. | Java {{ java_version }} is NOT installed"
```
---
<br>

## 📌 host.ini 예시
```ini
[Ubuntu_Servers:vars]
java_version=11
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Java 버전 선택 설치
- host.ini 의 java_version 변수를 통해 Java 버전 지정
- openjdk-{{ java_version }}-jdk 패키지 설치
---
### 2️⃣ 패키지 캐시 업데이트
- 최신 패키지 목록을 기준으로 안정적인 설치 수행
---
### 3️⃣ Java 설치 검증
- java -version 결과를 기반으로 설치 여부 확인
- 지정한 Java 버전이 정상적으로 적용되었는지 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert.. Java {{ java_version }} is installed]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Java {{ java_version }} installed successfully"
}
~~
```
---
