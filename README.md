# 15-Leafresh-CL
# ☁️ Cloud Repository
**Leafresh의 클라우드 운영팀 레포지토리입니다. 환영합니다!**
- **AWS, GCP 퍼블릭 클라우드**를 이용해 운영하고 있으며,
- **수동 배포 방식**과 **Github를 이용한 CI/CD**, **Terraform의 IaC 방식**을 버전별로 정리하였습니다!

> 프로젝트 상황에 따라 디렉토리 구조 등 내용이 변경될 수 있습니다.


<br>

---

## 📁 디렉토리 구조
```
(project root directory)
├── performance-test
│   ├── v1-bigbang
│   │   ├── load_k6.js
│   │   ├── result.json
│   │   └── result_stress.json
│   ├── v2-docker
│   │   └── init
│   └── v3-k8s
│       └── init
├── README.md
├── scripts
│   ├── v1-bigbang
│   │   ├── discord_notify.sh
│   │   ├── kill_process.sh
│   │   ├── restart_servers.sh
│   │   ├── sftp_uploads.sh
│   │   ├── show_log.sh
│   │   └── start_servers.sh
│   └── v2-docker
│       ├── ai-ci.yml
│       ├── be-ci.yml
│       └── fe-ci.yml
└── terraform
    ├── v2-docker
    │   └── init
    └── v3-k8s
        └── init

```

### 버전 구분 방법
- 버전은 **디렉토리**로 구분합니다.
- **v1**: **sftp**를 이용한 수동 배포
- **v2**: **Docker**와 Github Action을 이용한 **CI/CD** 배포
- **v3**: IaC 방식의 **Terraform** 배포

<br>

---

## 👥 작업자 정보

| 이름     | 닉네임        | 사진 |
|:----------|:----------------|:------|
| **닉네임** | `@jchanho99`   | `@pieceofizzy` |
| **사진** | <img src="https://github.com/jchanho99.png" width="100" height="100"/> | <img src="https://github.com/pieceofizzy.png" width="100" height="100"/> |

<br>
---

## 🛠 사용 스택

- **Google Cloud Platform (GCP)**
- **Amazon Web Services (AWS)**
- **Terraform**

<br>

---

## 🛠️ 코드 작성 규칙 
- **Terraform** 공식 포맷터인 `terraform fmt`를 사용하여 코드 스타일을 통일합니다.
- 

### 네이밍 방식
- 들여쓰기는 **2 spaces**로 통일한다. 
- 네이밍은 모두 **foo-bar** 형식을 사용한다.
- 모든 리소스에는 **tag**를  필수 작성한다.

### 태그 지정 방식
```hcl
tags = {
  Name        = "leafresh-vpc"
  Project     = "leafresh"
  Environment = "prod"        # dev, prod 등으로 구분
  Module      = "network"    # 모듈명 (network, compute, database, security, monitoring 등)
  Version     = "v2"         # Terraform 코드 버전
  Assignee    = "andrea"      # 작성자 이름
}
```

<br>

---


## 📖 협업 방식
- 변경사항 발생 시, **PR 작성 및 리뷰**를 진행한다.
- main 브랜치 병합 전, **`terraform validate`** 및 **`terraform plan`**를 수행하여 배포 전 문제 발생 확률을 낮춘다.
- 모듈 추가/수정 시, **`README.md`** 및 예시 코드를 업데이트한다.


### Terraform Plan & Apply 워크플로우 
1. 최신 코드 Pull
`git pull origin main`

2. 코드 수정 & 포맷 정리
`terraform fmt`

3. 문법 체크
`terraform validate`

4. 변경사항 확인
`terraform plan`

5. PR 생성 및 Plan 결과 첨부

6. 리뷰 완료 후 Merge

7. 실제 적용
`terraform apply`


### PR 리뷰 체크리스트

| 체크 항목 | 설명 |
|:----------|:-----|
| terraform fmt 적용 여부 | 코드 포맷팅 적용 확인 |
| 리소스 태그 삽입 여부 | 모든 리소스에 태그 삽입 여부 확인 |
| 버전 명시 여부 | versions.tf 파일 적절히 관리 여부 확인 |
| 민감 정보 노출 여부 | Secrets 직접 노출 방지 여부 확인 |
| 가독성 및 일관성 | 들여쓰기, 정렬, 빈줄 확인 |
| 리소스 네이밍 규칙 준수 | 2단어 이상 사용 시 '-'로 작성했는지 확인 |
| 모듈 사용 여부 | 리소스를 직접 작성하지 않고 module로 감쌌는지 |
| outputs.tf 작성 여부 | 주요 출력 값(outputs)을 정의했는지 |
| terraform plan 결과 검토 | 의도치 않은 리소스 삭제/변경 없는지 확인 |
