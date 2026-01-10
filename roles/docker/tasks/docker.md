# 🐳 Docker Engine 설치 및 설정 (Ansible)
- Ubuntu 서버에 **Docker Engine 최신 안정 버전 설치**
- **공식 Docker APT 저장소 + keyrings 방식** 사용
- **host.ini 변수 기반으로 Docker 데이터 디렉토리(data-root) 설정**
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. 패키지 업데이트
# -----------------------------------------------------
- name: "APT update"
  apt:
    update_cache: yes
    cache_valid_time: 3600

# -----------------------------------------------------
# 2. Docker 설치에 필요한 패키지 설치 (keyrings 방식)
# -----------------------------------------------------
- name: "Install required packages for Docker"
  apt:
    name:
      - ca-certificates
      - curl
      - gnupg
      - software-properties-common
    state: present

# -----------------------------------------------------
# 3. keyrings 디렉토리 생성
# -----------------------------------------------------
- name: "Create /etc/apt/keyrings directory"
  file:
    path: /etc/apt/keyrings
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 4. Docker GPG 키 추가 (keyrings)
# -----------------------------------------------------
- name: "Add Docker GPG key"
  shell: |
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  args:
    creates: /etc/apt/keyrings/docker.gpg

# -----------------------------------------------------
# 5. Docker 공식 APT 저장소 추가
# -----------------------------------------------------
- name: "Add Docker APT repository"
  copy:
    dest: /etc/apt/sources.list.d/docker.list
    owner: root
    group: root
    mode: '0644'
    content: |
      deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu {{ ansible_lsb.codename }} stable

# -----------------------------------------------------
# 6. Docker 저장소 반영
# -----------------------------------------------------
- name: "APT update after Docker repo added"
  apt:
    update_cache: yes

# -----------------------------------------------------
# 7. Docker Engine 설치
# -----------------------------------------------------
- name: "Install Docker Engine"
  apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    state: present

# -----------------------------------------------------
# 8. Docker data-root 디렉토리 생성
# -----------------------------------------------------
- name: "Create Docker data-root directory"
  file:
    path: "{{ docker_data_root }}"
    state: directory
    owner: root
    group: root
    mode: '0711'

# -----------------------------------------------------
# 9-1. Docker daemon.json 설정
# -----------------------------------------------------
- name: "Create /etc/docker directory exists"
  file:
    path: /etc/docker
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 9-2. Docker daemon.json 설정
# -----------------------------------------------------
- name: "Configure Docker daemon.json"
  copy:
    dest: /etc/docker/daemon.json
    owner: root
    group: root
    mode: '0644'
    content: |
      {
        "data-root": "{{ docker_data_root }}"
      }
  notify: Restart Docker

# -----------------------------------------------------
# 10. Docker 서비스 활성화 및 실행
# -----------------------------------------------------
- name: "Enable and start Docker service"
  systemd:
    name: docker
    enabled: yes
    state: started

# -----------------------------------------------------
# 11. Docker 실행 상태 검증
# -----------------------------------------------------
- name: "Check Docker service status"
  command: systemctl is-active docker
  register: docker_status
  changed_when: false

- name: "Assert Docker is running"
  assert:
    that:
      - docker_status.stdout == "active"
    success_msg: "Good!.. | Docker service is running"
    fail_msg: "ERROR!.. | Docker service is NOT running"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ APT 캐시 업데이트
- cache_valid_time 적용으로 불필요한 update 방지
---
### 2️⃣ Docker 설치 사전 패키지 설치
- ca-certificates, curl, gnupg 등 Docker 공식 권장 패키지
- keyrings 방식 사용을 위한 필수 구성
---
### 3️⃣ Docker 공식 GPG 키 등록
- /etc/apt/keyrings/docker.gpg 사용
- creates 옵션으로 멱등성 보장
---
### 4️⃣ Docker 공식 APT 저장소 등록
- Ubuntu 배포판 코드네임({{ ansible_lsb.codename }}) 자동 적용
- signed-by 옵션으로 보안 강화
---
### 5️⃣ Docker Engine 설치
- docker-ce
- docker-ce-cli
- containerd.io
---
### 6️⃣ Docker 데이터 디렉토리 분리
- host.ini에서 지정한 docker_data_root 값 사용
- 서버별 디스크 / 마운트 구조에 맞게 설정 가능
---
### 7️⃣ daemon.json 설정
- /etc/docker/daemon.json 생성
- 설정 변경 시에만 Docker 재시작 트리거
---
### 8️⃣ Docker 서비스 활성화
- systemd enable + start
---
### 9️⃣ Docker 상태 검증
- systemctl is-active docker 결과 기반 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert Docker is running]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Docker service is running"
}
~
```
---
