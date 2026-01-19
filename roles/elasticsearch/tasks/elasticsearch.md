# 🔍 Apache Elasticsearch (Ansible)

- Ubuntu 서버에 **Elasticsearch APT 기반 설치**
- **Elastic 공식 저장소 사용**
- 버전 고정 설치 및 설치 검증 포함

---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Elasticsearch APT GPG Key 등록
# -----------------------------------------------------
- name: "Add Elasticsearch GPG key"
  apt_key:
    url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
    state: present

# -----------------------------------------------------
# 2. Elasticsearch APT repository 추가
# -----------------------------------------------------
- name: "Add Elasticsearch APT repository"
  apt_repository:
    repo: "deb https://artifacts.elastic.co/packages/{{ elasticsearch_version.split('.')[0] }}.x/apt stable main"
    state: present
    filename: "elastic-{{ elasticsearch_version.split('.')[0] }}.x"
  register: elastic_repo

# -----------------------------------------------------
# 3. APT cache 업데이트 (repo 변경 시에만)
# -----------------------------------------------------
- name: "Update apt cache if repo changed"
  apt:
    update_cache: yes
  when: elastic_repo.changed

# -----------------------------------------------------
# 4. Elasticsearch 설치
# -----------------------------------------------------
- name: "Install Elasticsearch {{ elasticsearch_version }}"
  apt:
    name: "elasticsearch={{ elasticsearch_version }}"
    state: present

# -----------------------------------------------------
# 5. Elasticsearch 설치 검증
# -----------------------------------------------------
- name: "Get Elasticsearch version"
  command: /usr/share/elasticsearch/bin/elasticsearch --version
  register: es_version_check
  changed_when: false
  failed_when: false   # assert에서 실패 처리

- name: "Verify Elasticsearch installation"
  assert:
    that:
      - "'{{ elasticsearch_version }}' in es_version_check.stdout"
    success_msg: "Good!.. | Elasticsearch {{ elasticsearch_version }} installed successfully"
    fail_msg: "ERROR!.. | Elasticsearch version mismatch or not installed"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Elasticsearch GPG Key 등록
- Elastic 공식 패키지 서명 검증을 위한 GPG Key 등록
- APT 패키지 무결성 보장
---
### 2️⃣ Elasticsearch APT Repository 추가
- elasticsearch_version 기준으로 메이저 버전(x) 저장소 사용
- 예: 8.12.2 → 8.x
- /etc/apt/sources.list.d/elastic-8.x.list 파일 생성
---
### 3️⃣ APT Cache 업데이트
- Repository 변경이 발생한 경우에만 apt update 수행
- 불필요한 캐시 갱신 방지 (멱등성 유지)
---
### 4️⃣ Elasticsearch 설치
- 특정 버전(elasticsearch_version)으로 패키지 설치
- 버전 고정 설치로 운영 환경 안정성 확보
---
### 5️⃣ Elasticsearch 설치 검증
- elasticsearch --version 명령어로 실제 설치 버전 확인
- 기대 버전과 불일치 시 assert로 실패 처리
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Elasticsearch installation]
ok: [apserver] => {
    "msg": "Good!.. | Elasticsearch 8.12.2 installed successfully"
}
~
```
---
