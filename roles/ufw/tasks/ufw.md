# 🔥 방화벽(UFW) 비활성화 (Ansible)
- Ubuntu 기본 방화벽인 UFW(Uncomplicated Firewall) 를 비활성화한다.
- 서버 간 통신, 테스트 환경, 내부망 구성 시
방화벽으로 인한 포트 차단 이슈를 방지하기 위함이다.
---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# 방화벽(UFW) 비활성화
# -----------------------------------------------------

# UFW Service Disable
- name: "Disalbe UFW firewall"
  systemd:
    name: ufw
    enabled: false
    state: stopped

# 방화벽 비활성화 검증
- name: "Check.. UFW status.."
  command: systemctl is-active ufw
  register: ufw_status
  failed_when: false
  changed_when: false

- name: "Status.. UFW.."
  debug:
    msg: "Good!.. | UFW is disabled (inactive).."
  when: ufw_status.stdout != "active"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ UFW 서비스 중지
- systemd 모듈을 사용하여 ufw 서비스 중지
- 즉시 방화벽 기능 비활성화
---
### 2️⃣ UFW 자동 시작 비활성화
- enabled: false 설정으로
- 시스템 재부팅 후에도 ufw 자동 실행 방지
---
### 3️⃣ 방화벽 상태 검증
- systemctl is-active ufw 명령으로 상태 확인
- active가 아닌 경우에만 성공 메시지 출력
- task 실패 없이 상태만 검증하도록 구성
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Status.. UFW..]
ok: [192.168.56.60] => {
    "msg": "Good!.. | UFW is disabled (inactive).."
}
~~
```
---
