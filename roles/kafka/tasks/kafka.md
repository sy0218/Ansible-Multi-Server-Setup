# ☕ Apache Kafka 설치 및 설정 (Ansible)
- Ubuntu 서버에 **Apache Kafka 바이너리 설치**
- **지정된 디렉토리 구조로 설치 및 심볼릭 링크 구성**
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Kafka 설치 디렉토리 생성
# -----------------------------------------------------
- name: "Create Kafka install directory"
  file:
    path: "{{ kafka_install_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. Kafka 다운로드
# -----------------------------------------------------
- name: "Download Kafka"
  get_url:
    url: "{{ kafka_url }}"
    dest: "/tmp/{{ kafka_url | basename }}"
    mode: '0644'

# -----------------------------------------------------
# 3. Kafka 압축 해제
# -----------------------------------------------------
- name: "Extract Kafka"
  unarchive:
    src: "/tmp/{{ kafka_url | basename }}"
    dest: "{{ kafka_install_dir }}"
    remote_src: yes
    creates: "{{ kafka_install_dir }}/{{ (kafka_url | basename) | regex_replace('.tgz','') }}"

# -----------------------------------------------------
# 4. Kafka 심볼릭 링크 생성
# -----------------------------------------------------
- name: "Create Kafka symlink"
  file:
    src: "{{ kafka_install_dir }}/{{ (kafka_url | basename) | regex_replace('.tgz','') }}"
    dest: "{{ kafka_install_dir }}/kafka"
    state: link
    force: yes

# -----------------------------------------------------
# 5. Kafka 로그 디렉토리 생성
# -----------------------------------------------------
- name: "Create Kafka log directory"
  file:
    path: "{{ kafka_log_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 6. Kafka 설치 검증
# -----------------------------------------------------
- name: "Check Kafka start script"
  stat:
    path: "{{ kafka_install_dir }}/kafka/bin/kafka-server-start.sh"
  register: kafka_bin_check

- name: "Verify Kafka installation"
  assert:
    that:
      - kafka_bin_check.stat.exists
    success_msg: "Good!.. | Kafka installed successfully ({{ kafka_install_dir }}/kafka)"
    fail_msg: "ERROR!.. | Kafka binary not found. Check download or extraction."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Kafka 설치 디렉토리 생성
- Kafka 바이너리를 설치할 기본 경로 생성
---
### 2️⃣ Kafka 바이너리 다운로드
- host.ini의 kafka_url 변수 기반 → /tmp 디렉토리에 tar.gz 다운로드
---
### 3️⃣ Kafka 압축 해제
- 원격 서버에서 직접 압축 해제
- creates 옵션으로 멱등성 보장
---
### 4️⃣ Kafka 심볼릭 링크 생성
- 압축 해제 후 버전 디렉토리 → kafka 심볼릭 링크 생성
---
### 5️⃣ Kafka 로그 디렉토리 생성
- host.ini의 kafka_log_dir 변수 사용
- Kafka 로그 파일 저장용 디렉토리 생성
---
### 6️⃣ Kafka 설치 검증
- kafka-server-start.sh 존재 여부 확인
- 설치 및 심볼릭 링크 정상 여부 assert 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Kafka installation]
ok: [apserver] => {
    "msg": "Good!.. | Kafka installed successfully (/application/kafka)"
}
~
```
---
