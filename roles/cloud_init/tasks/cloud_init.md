# ☁️ cloud-init 비활성화 (Ansible)
- 부팅 시 cloud-init이 네트워크/hostname/사용자 설정을 자동 변경하지 못하도록 차단
- `/etc/cloud/cloud-init.disabled` 플래그 파일 존재 시 cloud-init 실행 skip
- **사전 체크 → 미존재 시 생성 → 사후 검증** 흐름으로 멱등성 보장
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# cloud-init 비활성화 플래그 사전 상태 확인 (멱등성 사전 체크)
# -----------------------------------------------------
- name: "Check pre-existing cloud-init disabled flag"
  stat:
    path: /etc/cloud/cloud-init.disabled
  register: cloud_init_pre_check

# -----------------------------------------------------
# /etc/cloud 디렉토리 보장 (없을 때만)
# -----------------------------------------------------
- name: "Ensure /etc/cloud directory exists"
  file:
    path: /etc/cloud
    state: directory
    owner: root
    group: root
    mode: '0755'
  when: not cloud_init_pre_check.stat.exists

# -----------------------------------------------------
# 플래그 파일 생성 (없을 때만 touch → 재실행 시 skip 으로 changed=0 보장)
# -----------------------------------------------------
- name: "Create cloud-init disabled flag"
  file:
    path: /etc/cloud/cloud-init.disabled
    state: touch
    owner: root
    group: root
    mode: '0644'
  when: not cloud_init_pre_check.stat.exists

# -----------------------------------------------------
# cloud-init 비활성화 검증
# -----------------------------------------------------
- name: "Check cloud-init disabled flag"
  stat:
    path: /etc/cloud/cloud-init.disabled
  register: cloud_init_check

- name: "Assert cloud-init disabled"
  assert:
    that:
      - cloud_init_check.stat.exists
    success_msg: "Good!.. | cloud-init is disabled (flag file present)"
    fail_msg: "ERROR!.. | cloud-init.disabled flag file is missing"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 사전 상태 확인
- `stat`으로 `/etc/cloud/cloud-init.disabled` 존재 여부 조회
- `state: touch`는 매번 mtime을 갱신해 changed 유발 → 반드시 사전 체크 필요
---
### 2️⃣ 미존재 시에만 생성 (멱등성 핵심)
- `when: not cloud_init_pre_check.stat.exists` → 이미 있으면 두 task 모두 skip
- `/etc/cloud` 디렉토리 보장 후 플래그 파일 touch
- 재실행 시 **changed=0** 보장
---
### 3️⃣ 비활성화 검증
- 플래그 파일 존재 여부를 다시 `stat`으로 확인
- 기존 조건부 `debug` → `assert`로 격상해 실제 실패 시 플레이북 중단
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Create cloud-init disabled flag]
skipping: [192.168.56.60]

TASK [Assert cloud-init disabled]
ok: [192.168.56.60] => {
    "msg": "Good!.. | cloud-init is disabled (flag file present)"
}
```
---
