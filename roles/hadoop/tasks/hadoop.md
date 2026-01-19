# 🐘 Apache Hadoop 설치 및 설정 (Ansible)

- Ubuntu 서버에 **Apache Hadoop 바이너리 설치**
- **지정된 디렉토리 구조로 설치 및 심볼릭 링크 구성**

---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Hadoop 설치 디렉토리 생성
# -----------------------------------------------------
- name: "Create Hadoop install directory"
  file:
    path: "{{ hadoop_install_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. Hadoop 다운로드
# -----------------------------------------------------
- name: "Download Hadoop"
  get_url:
    url: "{{ hadoop_url }}"
    dest: "/tmp/{{ hadoop_url | basename }}"
    mode: '0644'
    force: no

# -----------------------------------------------------
# 3. Hadoop 압축 해제
# -----------------------------------------------------
- name: "Extract Hadoop"
  unarchive:
    src: "/tmp/{{ hadoop_url | basename }}"
    dest: "{{ hadoop_install_dir }}"
    remote_src: yes
    creates: "{{ hadoop_install_dir }}/{{ (hadoop_url | basename) | regex_replace('.tar.gz','') }}"

# -----------------------------------------------------
# 4. Hadoop 심볼릭 링크 생성
# -----------------------------------------------------
- name: "Create Hadoop symlink"
  file:
    src: "{{ hadoop_install_dir }}/{{ (hadoop_url | basename) | regex_replace('.tar.gz','') }}"
    dest: "{{ hadoop_install_dir }}/hadoop"
    state: link
    force: yes

# -----------------------------------------------------
# 5. Hadoop 설치 검증
# -----------------------------------------------------
- name: "Check Hadoop binary"
  stat:
    path: "{{ hadoop_install_dir }}/hadoop/bin/hadoop"
  register: hadoop_bin_check

- name: "Verify Hadoop installation"
  assert:
    that:
      - hadoop_bin_check.stat.exists
    success_msg: "Good!.. | Hadoop installed successfully ({{ hadoop_install_dir }}/hadoop)"
    fail_msg: "ERROR!.. | Hadoop binary not found. Check download or extraction."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Hadoop 설치 디렉토리 생성
- Apache Hadoop 바이너리를 설치할 기본 경로 생성
- hadoop_install_dir 변수 기반 디렉토리 생성
---
### 2️⃣ Hadoop 바이너리 다운로드
- host.ini에 정의된 hadoop_url 변수 사용
- /tmp 디렉토리에 tar.gz 파일 다운로드
- force: no 옵션으로 재다운로드 방지
---
### 3️⃣ Hadoop 압축 해제
- 원격 서버에서 직접 압축 해제 (remote_src: yes)
- creates 옵션으로 멱등성 보장
---
### 4️⃣ Hadoop 심볼릭 링크 생성
- 버전 디렉토리 → hadoop 고정 심볼릭 링크 생성
- Hadoop 버전 업그레이드 시 경로 변경 최소화
---
### 5️⃣ Hadoop 설치 검증
- hadoop/bin/hadoop 실행 파일 존재 여부 확인
- 설치 및 심볼릭 링크 정상 여부 assert로 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Hadoop installation]
ok: [apserver] => {
    "msg": "Good!.. | Hadoop installed successfully (/application/hadoop)"
}
~
```
---
