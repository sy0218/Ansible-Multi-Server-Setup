# 🌐 NIC 이름 설정 (Ansible)
- 예측 가능한 NIC 이름(`ens33` 등) 비활성화 → 전통적 이름(`eth0`) 사용
- GRUB 커널 파라미터 `net.ifnames=0 biosdevname=0`로 시스템 전역 적용
- **사전 체크 → 미설정 시 적용 → 사후 검증** 흐름으로 멱등성 보장
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 설정 전 GRUB NIC 파라미터 상태 확인 (멱등성 사전 체크)
# -----------------------------------------------------
- name: "Check pre-configured GRUB NIC parameter"
  shell: 'grep -E ''^GRUB_CMDLINE_LINUX_DEFAULT="net\.ifnames=0 biosdevname=0"'' /etc/default/grub'
  register: grub_pre_check
  changed_when: false
  failed_when: false

# -----------------------------------------------------
# 미설정 시에만 GRUB NIC 이름 고정 적용 (이미 설정된 경우 skip)
# -----------------------------------------------------
- name: "Configure GRUB NIC parameter (fix to eth*)"
  lineinfile:
    path: /etc/default/grub
    regexp: '^GRUB_CMDLINE_LINUX_DEFAULT='
    line: 'GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0"'
  when: grub_pre_check.rc != 0
  notify: update-grub

# -----------------------------------------------------
# GRUB NIC 설정 검증
# -----------------------------------------------------
- name: "Check applied GRUB NIC parameter"
  shell: "grep '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub"
  register: grub_check
  changed_when: false

- name: "Assert GRUB NIC parameter applied"
  assert:
    that:
      - "'net.ifnames=0' in grub_check.stdout"
      - "'biosdevname=0' in grub_check.stdout"
    success_msg: "Good!.. | NIC name configuration applied: {{ grub_check.stdout }}"
    fail_msg: "ERROR!.. | GRUB NIC parameter NOT applied"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 사전 상태 확인
- `/etc/default/grub`에서 정확한 라인 존재 여부를 `grep -E`로 조회
- `changed_when: false`, `failed_when: false`로 결과만 수집
---
### 2️⃣ 미설정 시에만 적용 (멱등성 핵심)
- `when: grub_pre_check.rc != 0` → 이미 설정돼 있으면 task 자체 skip
- 변경 발생 시에만 `update-grub` handler가 호출되어 `grub-mkconfig` 재생성
- 재실행 시 **changed=0** 보장
---
### 3️⃣ 설정 검증
- `grep`으로 현재 라인 다시 읽어 `assert`
- `net.ifnames=0`, `biosdevname=0` 두 토큰이 모두 포함됐는지 검증
- 기존 `debug` 출력 → `assert`로 격상해 실제 검증 효과 확보
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Configure GRUB NIC parameter (fix to eth*)]
skipping: [192.168.56.60]

TASK [Assert GRUB NIC parameter applied]
ok: [192.168.56.60] => {
    "msg": "Good!.. | NIC name configuration applied: GRUB_CMDLINE_LINUX_DEFAULT=\"net.ifnames=0 biosdevname=0\""
}
```
> ⚠️ GRUB 변경 시 커널 파라미터는 **다음 부팅부터** 실제 NIC 이름에 반영됨
---
