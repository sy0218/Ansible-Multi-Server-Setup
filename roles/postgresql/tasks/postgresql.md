# 🐘 PostgreSQL 설치 및 컨테이너 실행 (Ansible)
- Ubuntu 서버에서 **PostgreSQL 데이터 디렉토리 생성**
- **PostgreSQL Docker 컨테이너 실행 및 상태 검증**
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. PostgreSQL 데이터 디렉토리 생성
# -----------------------------------------------------
- name: "Create PostgreSQL data directory"
  file:
    path: "{{ pg_data }}"
    state: directory
    owner: root
    group: root
    mode: '0755'
  check_mode: no

# -----------------------------------------------------
# 2. PostgreSQL 컨테이너 실행
# -----------------------------------------------------
- name: "Run PostgreSQL container"
  docker_container:
    name: "{{ pg_container }}"
    image: "postgres:{{ pg_version }}"
    state: started
    restart_policy: unless-stopped
    published_ports:
      - "{{ pg_port }}:{{ pg_port }}"
    volumes:
      - "{{ pg_data }}:/var/lib/postgresql/data"
    env:
      POSTGRES_PASSWORD: "{{ pg_pass }}"
    recreate: no
  register: pg_container_result

- name: "Debug container status"
  debug:
    msg: "PostgreSQL container '{{ pg_container }}' was {{ 'created/started' if pg_container_result.changed else 'already running' }}"

# -----------------------------------------------------
# 3. PostgreSQL 컨테이너 상태 검증
# -----------------------------------------------------
- name: "Verify PostgreSQL container is running"
  shell: "docker ps --filter 'name={{ pg_container }}' --filter 'status=running' --format '{{\"{{.Names}}\"}}'"
  register: pg_ps
  changed_when: false

- name: "Assert PostgreSQL container running"
  assert:
    that:
      - "'{{ pg_container }}' in pg_ps.stdout"
    success_msg: "Good!.. | PostgreSQL container '{{ pg_container }}' is running"
    fail_msg: "ERROR!.. | PostgreSQL container '{{ pg_container }}' is NOT running"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ PostgreSQL 데이터 디렉토리 생성
- PostgreSQL 컨테이너에서 데이터를 저장할 디렉토리 생성
---
### 2️⃣ PostgreSQL Docker 컨테이너 실행
- 포트, 데이터 볼륨, 비밀번호, 재시작 정책 설정
- 이미 컨테이너가 있으면 재생성하지 않고 멱등성 확보
---
### 3️⃣ PostgreSQL 컨테이너 상태 검증
- docker ps로 컨테이너 실행 상태 확인
- assert 모듈로 컨테이너 정상 실행 여부 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert PostgreSQL container running]
ok: [apserver] => {
    "msg": "Good!.. | PostgreSQL container 'job_postgres' is running"
}
~
```
---
