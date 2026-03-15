# 🍃 Apache NiFi 설치 및 설정 (Ansible)
- Ubuntu 서버에 **Apache NiFi 바이너리 설치**
- **지정된 디렉토리 구조로 설치 및 심볼릭 링크 구성**
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. NiFi 설치 디렉토리 생성
# -----------------------------------------------------
- name: "Create NiFi install directory"
  file:
    path: "{{ nifi_install_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. NiFi 다운로드
# -----------------------------------------------------
- name: "Download NiFi"
  get_url:
    url: "{{ nifi_url }}"
    dest: "/tmp/{{ nifi_url | basename }}"
    mode: '0644'
    force: no

# -----------------------------------------------------
# 3. NiFi 압축 해제
# -----------------------------------------------------
- name: "Extract NiFi"
  unarchive:
    src: "/tmp/{{ nifi_url | basename }}"
    dest: "{{ nifi_install_dir }}"
    remote_src: yes
    creates: "{{ nifi_install_dir }}/{{ (nifi_url | basename) | regex_replace('.zip','') }}"

# -----------------------------------------------------
# 4. NiFi 심볼릭 링크 생성
# -----------------------------------------------------
- name: "Create NiFi symlink"
  file:
    src: "{{ nifi_install_dir }}/{{ (nifi_url | basename) | regex_replace('.zip','') }}"
    dest: "{{ nifi_install_dir }}/nifi"
    state: link
    force: yes

# -----------------------------------------------------
# 5. NiFi 설치 검증
# -----------------------------------------------------
- name: "Check NiFi start script"
  stat:
    path: "{{ nifi_install_dir }}/nifi/bin/nifi.sh"
  register: nifi_bin_check

- name: "Verify NiFi installation"
  assert:
    that:
      - nifi_bin_check.stat.exists
    success_msg: "Good!.. | NiFi installed successfully ({{ nifi_install_dir }}/nifi)"
    fail_msg: "ERROR!.. | NiFi binary not found. Check download or extraction."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ NiFi 설치 디렉토리 생성
- NiFi 바이너리를 설치할 기본 경로 생성
---
### 2️⃣ NiFi 바이너리 다운로드
- host.ini의 nifi_url 변수 기반 → /tmp 디렉토리에 zip 다운로드
---
### 3️⃣ NiFi 압축 해제
- 원격 서버에서 직접 압축 해제
- creates 옵션으로 멱등성 보장
---
### 4️⃣ NiFi 심볼릭 링크 생성
- 압축 해제 후 버전 디렉토리 → nifi 심볼릭 링크 생성
---
### 5️⃣ NiFi 설치 검증
- nifi.sh 존재 여부 확인
- 설치 및 심볼릭 링크 정상 여부 assert 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify NiFi installation]
ok: [apserver] => {
    "msg": "Good!.. | NiFi installed successfully (/application/nifi)"
}
~
```
---
