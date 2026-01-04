# cloud-init 비활성화 (Ansible)
- cloud-init이 부팅 시 네트워크, hostname, 사용자 설정을
자동으로 변경하는 것을 방지하기 위해 비활성화한다.
---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# cloud-init 비활성화
# -----------------------------------------------------

- name: "Disable Cloud-Init"
  file:
    path: "{{ item.path }}"
    state: "{{ item.state }}"
    owner: root
    group: root
    mode: "{{ item.mode }}"
  loop:
    - { path: /etc/cloud, state: directory, mode: '0755' }
    - { path: /etc/cloud/cloud-init.disabled, state: touch, mode: '0644' }

# cloud-init 비활성화 플래그 파일 존재 여부 확인
- name: "Check.. cloud-init disabled flag file.."
  stat:
    path: /etc/cloud/cloud-init.disabled
  register: cloud_init_check

- name: "Status.. cloud-init.."
  debug:
    msg: "Good!.. | cloud-init is disabled.."
  when: cloud_init_check.stat.exists
```
---
<br>

## 🛠 작업 내용
### 1️⃣ cloud-init 비활성화 플래그 생성
- /etc/cloud/cloud-init.disabled 파일 생성
- 해당 파일 존재 시 cloud-init 실행 차단
---
### 2️⃣ cloud-init 디렉토리 보장
- /etc/cloud 디렉토리 미존재 시 생성
- 권한 및 소유자 설정 포함
---
### 3️⃣ 비활성화 상태 검증
- 플래그 파일 존재 여부로 비활성화 확인
- 조건부 debug 메시지 출력
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Status.. cloud-init..]
ok: [192.168.56.60] => {
    "msg": "Good!.. | cloud-init is disabled.."
}
~~~
```
---
