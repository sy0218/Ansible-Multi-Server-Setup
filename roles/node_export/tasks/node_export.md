# ⚙️ Node Exporter 설치 및 검증 (Ansible)
- Ubuntu 서버에 **Node Exporter 바이너리 설치**
- **지정된 디렉토리 구조로 다운로드 → 압축 → 설치 검증**
- **심볼릭 링크는 사용하지 않고, 멱등성 보장**
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. node_export 설치 디렉토리 생성
# -----------------------------------------------------
- name: "Create node_export base directory"
  file:
    path: "{{ ne_install_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. node_export 다운로드
# -----------------------------------------------------
- name: "Download node_export"
  get_url:
    url: "{{ ne_url }}"
    dest: "/tmp/{{ ne_url | basename }}"
    mode: '0644'
    force: no   # 이미 존재하면 재다운로드 안 함

# -----------------------------------------------------
# 3. node_export 압축 해제
# -----------------------------------------------------
- name: "Extract node_export"
  unarchive:
    src: "/tmp/{{ ne_url | basename }}"
    dest: "{{ ne_install_dir }}"
    remote_src: yes
    creates: "{{ ne_install_dir }}/{{ (ne_url | basename) | regex_replace('.tar.gz','') }}"
    # 이미 압축 풀려있으면 실행 안 함 (멱등성 보장)

# -----------------------------------------------------
# 4. node_export 설치 검증
# -----------------------------------------------------
- name: "Check Node Exporter binary existence"
  stat:
    path: "{{ ne_install_dir }}/{{ (ne_url | basename) | regex_replace('.tar.gz','') }}/node_exporter"
  register: ne_bin_check

- name: "Verify Node Exporter Installation"
  assert:
    that:
      - ne_bin_check.stat.exists
    fail_msg: "Node Exporter binary not found at {{ ne_install_dir }}/{{ (ne_url | basename) | regex_replace('.tar.gz','') }}/node_exporter. Please check extraction."
    success_msg: "Node Exporter installation verified: Binary exists at the expected path."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Node Exporter 설치 디렉토리 생성
- 설치할 기본 디렉토리 생성
---
### 2️⃣ Node Exporter 다운로드
- ne_url 변수 기반 tar.gz 파일 다운로드
- /tmp 디렉토리에 저장
- 이미 존재하면 다운로드 건너뜀 (멱등성 보장)
---
### 3️⃣ Node Exporter 압축 해제
- 원격 서버에서 직접 압축 해제
- creates 옵션으로 멱등성 보장
---
### 4️⃣ Node Exporter 설치 검증
- 압축 해제 디렉토리 안의 node_exporter 바이너리 존재 여부 확인
- 존재하지 않으면 fail, 존재하면 success 메시지 출력
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Node Exporter Installation]
ok: [apserver] => {
    "msg": "Node Exporter installation verified: Binary exists at the expected path."
}
~~
```
---
