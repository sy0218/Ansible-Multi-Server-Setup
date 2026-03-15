# 🔍 Filebeat (Ansible)

- Ubuntu 서버에 **Filebeat APT 기반 설치**
- **Elastic 공식 저장소 사용**
- 버전 고정 설치 및 설치 검증 포함

---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Filebeat APT GPG Key 등록
# -----------------------------------------------------
- name: "Add Filebeat GPG key"
  apt_key:
    url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
    state: present

# -----------------------------------------------------
# 2. Filebeat APT repository 추가
# -----------------------------------------------------
- name: "Add Filebeat APT repository"
  apt_repository:
    repo: "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main"
    state: present
    filename: "elastic-8.x"
  register: filebeat_repo

# -----------------------------------------------------
# 3. APT cache 업데이트 (repo 변경 시에만)
# -----------------------------------------------------
- name: "Update apt cache if repo changed"
  apt:
    update_cache: yes
  when: filebeat_repo.changed

# -----------------------------------------------------
# 4. Filebeat 설치
# -----------------------------------------------------
- name: "Install Filebeat {{ filebeat_version }}"
  apt:
    name: "filebeat={{ filebeat_version }}"
    state: present

# -----------------------------------------------------
# 5. Filebeat 설치 검증
# -----------------------------------------------------
- name: "Get Filebeat version"
  command: filebeat version
  register: filebeat_version_check
  changed_when: false
  failed_when: false

- name: "Verify Filebeat installation"
  assert:
    that:
      - "'{{ filebeat_version }}' in filebeat_version_check.stdout"
    success_msg: "Good!.. | Filebeat {{ filebeat_version }} installed successfully"
    fail_msg: "ERROR!.. | Filebeat version mismatch or not installed"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Filebeat GPG Key 등록
- Elastic 공식 패키지 서명 검증을 위한 GPG Key 등록
- APT 패키지 무결성 보장
---
### 2️⃣ Filebeat APT Repository 추가
- Filebeat 8.x 저장소 사용
- `/etc/apt/sources.list.d/elastic-8.x.list` 파일 생성
---
### 3️⃣ APT Cache 업데이트
- Repository 변경이 발생한 경우에만 `apt update` 수행
- 불필요한 캐시 갱신 방지 (멱등성 유지)
---
### 4️⃣ Filebeat 설치
- 특정 버전(`filebeat_version`)으로 패키지 설치
- 버전 고정 설치로 운영 환경 안정성 확보
---
### 5️⃣ Filebeat 설치 검증
- `filebeat version` 명령어로 실제 설치 버전 확인
- 기대 버전과 불일치 시 assert로 실패 처리
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Filebeat installation]
ok: [apserver] => {
    "msg": "Good!.. | Filebeat 8.12.2 installed successfully"
}
~
```
---
