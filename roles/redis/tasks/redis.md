# 🟢 Redis 설치 및 컨테이너 실행 (Ansible)
- Ubuntu 서버에서 **Redis 데이터 디렉토리 생성**
- **Redis Docker 컨테이너 실행 및 상태 검증**
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Redis 데이터 디렉토리 생성
# -----------------------------------------------------
- name: "Create Redis data directory"
  file:
    path: "{{ redis_data }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. Redis 컨테이너 실행
# -----------------------------------------------------
- name: "Run Redis container"
  docker_container:
    name: "{{ redis_container }}"
    image: redis:7
    state: started
    restart_policy: unless-stopped
    published_ports:
      - "{{ redis_port }}:{{ redis_port }}"
    volumes:
      - "{{ redis_data }}:/data"
    command: >
      redis-server
      --requirepass {{ redis_pass }}
      --appendonly no
      --save 600 1
    recreate: no

# -----------------------------------------------------
# 3. Redis 컨테이너 상태 검증
# -----------------------------------------------------
- name: "Verify Redis container is running"
  shell: "docker ps --filter 'name={{ redis_container }}' --filter 'status=running' --format '{{\"{{.Names}}\"}}'"
  register: redis_ps
  changed_when: false

- name: "Assert Redis container running"
  assert:
    that:
      - "'{{ redis_container }}' in redis_ps.stdout"
    success_msg: "Good!.. | Redis container '{{ redis_container }}' is running"
    fail_msg: "ERROR!.. | Redis container '{{ redis_container }}' is NOT running"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Redis 데이터 디렉토리 생성
- Redis 컨테이너에서 데이터를 저장할 디렉토리 생성
---
### 2️⃣ Redis Docker 컨테이너 실행
- 포트, 데이터 볼륨, 비밀번호, 재시작 정책 설정
---
### 3️⃣ Redis 컨테이너 상태 검증
- docker ps로 컨테이너 실행 상태 확인
- assert 모듈로 컨테이너 정상 실행 여부 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert Redis container running]
ok: [apserver] => {
    "msg": "Good!.. | Redis container 'redis_server' is running"
}
~
```
---
