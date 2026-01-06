# 🧑‍💻 시스템 공통 Bash 환경 설정 (Common Bash)
- 모든 서버에 공통 Bash 환경 설정을 적용하여 운영 일관성을 유지하고
- 사용자 실수 방지를 위해 alias와 프롬프트를 통일합니다.
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 시스템 공통 Bash 환경 설정
# -----------------------------------------------------

# /etc/job_project.conf 생성
- name: "Create /etc/job_project.conf from inventory variables"
  copy:
    dest: /etc/job_project.conf
    owner: root
    group: root
    mode: '0644'
    content: |
      {% for env in job_project_envs.split(';') %}
      export {{ env }}
      {% endfor %}

# Bash 공통 설정 적용
- name: "Apply common bash settings to system targets"
  blockinfile:
    path: "{{ item }}"
    marker: "# {mark} ANSIBLE COMMON BASH CONFIG"
    block: |
      # Load project environment variables
      if [ -f /etc/job_project.conf ]; then
          source /etc/job_project.conf
      fi

      # Safe aliases
      alias rm='rm -i'
      alias cp='cp -i'
      alias mv='mv -i'

      # Prompt
      PS1='[\h:\w] '
    create: yes
  loop:
    - /root/.bashrc
    - /etc/skel/.bashrc

# 검증
- name: "Verify job_project.conf exists"
  stat:
    path: /etc/job_project.conf
  register: job_conf

- name: "Verify bash common config applied"
  shell: grep -q "ANSIBLE COMMON BASH CONFIG" /root/.bashrc
  register: bash_check
  changed_when: false

- name: "Validation result"
  assert:
    that:
      - job_conf.stat.exists
      - bash_check.rc == 0
    success_msg: "Good!.. | Common bash environment is correctly applied"
    fail_msg: "ERROR!.. | Common bash environment is NOT applied"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 공통 환경 설정 파일 생성
- /etc/job_project.conf 파일 생성
- root 소유 및 0644 권한
- 공통 환경 변수 및 설정을 분리 관리 가능
---
### 2️⃣ Bash 공통 설정 적용
- /root/.bashrc, /etc/skel/.bashrc에 적용
- blockinfile 사용으로 멱등성 보장
- 공통 환경 파일 source
- rm / cp / mv 명령에 -i alias 적용
- 프롬프트(PS1) 통일
---
### 3️⃣ 설정 검증
- root 계정 .bashrc에 설정 블록 존재 여부 확인
- 설정 누락 시 실패하도록 검증 로직 구성
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Validation result]
ok: [192.168.56.60] => {
    "msg": "Common bash environment is correctly applied"
}
~
```
