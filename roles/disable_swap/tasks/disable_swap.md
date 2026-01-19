# ⏱ Swap 비활성화 (Ansible)

- 시스템에서 **스왑(Swap) 사용을 비활성화**하여 메모리 관리 및 성능 최적화를 수행합니다.

---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 스왑(Swap) 비활성화
# -----------------------------------------------------

# Swap 끄기 (멱등성, 이미 꺼져 있어도 안전)
- name: "Disable all swap"
  command: swapoff -a
  become: true
  changed_when: false

# fstab에서 swap 주석 처리 (재부팅 시 활성화 방지)
- name: "Comment out swap in /etc/fstab if not already"
  replace:
    path: /etc/fstab
    regexp: '^([^#].*swap.*)$'
    replace: '# \1'
  become: true
  register: fstab_update
  changed_when: fstab_update.changed

# Swap 비활성화 검증
- name: "Check active swap devices"
  command: swapon --noheadings
  register: swap_status
  changed_when: false
  become: true

- name: "Assert swap is disabled"
  assert:
    that:
      - swap_status.stdout_lines | length == 0
    success_msg: "Good!.. | Swap is disabled"
    fail_msg: "ERROR!.. | Swap is still enabled"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 스왑 끄기
- swapoff -a 명령으로 현재 활성화된 모든 스왑 비활성화
- 이미 꺼져 있어도 안전하게 처리(멱등성 보장)
---
### 2️⃣ 재부팅 후 활성화 방지
- /etc/fstab 파일 내 swap 항목 주석 처리
- 재부팅 시 swap이 자동으로 활성화되지 않도록 설정
---
### 3️⃣ 비활성화 검증
- swapon --noheadings로 활성 스왑 장치 확인
- 활성 스왑 장치가 없으면 성공 메시지 출력
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert swap is disabled]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Swap is disabled"
}
~
```
---
