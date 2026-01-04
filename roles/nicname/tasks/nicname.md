
# 🌐 NIC 이름 설정 (Ansible)

- 예측 가능한 네트워크 인터페이스 이름(`ens33` 등)을 비활성화하고  
  전통적인 인터페이스 이름(`eth0`)을 사용하도록 설정한다.
- GRUB 커널 파라미터를 통해 시스템 전역에 적용한다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# NIC Name Configuration
# -----------------------------------------------------

- name: "Change NIC name configuration"
  lineinfile:
    path: /etc/default/grub
    regexp: '^GRUB_CMDLINE_LINUX_DEFAULT='
    line: 'GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0"'
  notify: update-grub

# NIC 설정 검증
- name: "Check.. GRUB NIC configuration.."
  shell: "grep 'GRUB_CMDLINE_LINUX_DEFAULT' /etc/default/grub"
  register: grub_check
  changed_when: false

- name: "Status.. NIC config.."
  debug:
    msg: "Good!.. | {{ grub_check.stdout_lines }} configuration successfully.."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ NIC 이름 고정 설정
- /etc/default/grub 파일에 커널 파라미터 설정
- net.ifnames=0 biosdevname=0 옵션 적용
- 인터페이스 이름을 eth0, eth1 형식으로 고정
---
### 2️⃣ GRUB 설정 반영
- 설정 변경 시 update-grub handler 호출
- 커널 설정은 다음 부팅 시 적용됨
---
### 3️⃣ 설정 검증
- GRUB 설정 파일 기준으로 실제 반영 여부 확인
- 단순 실행 성공이 아닌 설정 값 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Status.. NIC config..]
ok: [192.168.56.60] => {
    "msg": "Good!.. | ['GRUB_CMDLINE_LINUX_DEFAULT=\"net.ifnames=0 biosdevname=0\"'] configuration successfully.."
}
~~~
```
---
