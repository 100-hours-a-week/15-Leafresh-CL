# 15-Leafresh-CL
# ☁️ Cloud Repository

## 📁 디렉토리 구조\
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

````

---

## 👥 작업자 정보

| 이름     | 닉네임        | 사진 |
|:----------|:----------------|:------|
| **닉네임** | `@jchanho99`   | `@pieceofizzy` |
| **사진** | <img src="https://github.com/jchanho99.png" width="100" height="100"/> | <img src="https://github.com/pieceofizzy.png" width="100" height="100"/> |

---

## 🛠 사용 스택

- **Google Cloud Platform (GCP)**
- **Amazon Web Services (AWS)**
- **Terraform**

---

## 📝 파일 작성 규칙

- `-` 기호를 사용하여 파일/스크립트 이름을 구성합니다.
- 들여쓰기는 **탭 2칸**을 기본으로 합니다.
- 스크립트 파일 작성 시 반드시 실행 권한을 부여해야 합니다:

```bash
chmod +x [script명].sh
````

---

## 🔧 변수 작성 규칙

변수는 다음과 같은 네이밍 룰을 따릅니다:

```
leafresh-[서비스 종류]-[역할](-[환경: dev or prod or gpu])
```

### 예시

* `leafresh-gce-fe-dev`
* `leafresh-gce-db-prod`
* `leafresh-gce-ai-image-dev`

---

## 📌 기타 참고사항

* **`performance-test`**, **`scripts`**, **`terraform`** 디렉토리는 버전별로 (`v1-`, `v2-`, `v3-`) 관리됩니다.
* 주요 환경은 `v2-docker`, `v3-k8s` 기준으로 운영됩니다.
