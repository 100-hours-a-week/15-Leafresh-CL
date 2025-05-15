# 15-Leafresh-CL
# ☁️ Cloud Repository

## 📁 디렉토리 구조

물론입니다. 전체 내용을 다시 깔끔하게 구성한 `README.md` 마크다운을 아래에 제공합니다. 복사해서 그대로 사용하실 수 있습니다.

---

```markdown
# ☁️ Cloud Repository

## 📁 디렉토리 구조

```

.
├── performance-test
│   ├── v1-bigbang
│   │   ├── load\_k6.js
│   │   ├── result.json
│   │   └── result\_stress.json
│   ├── v2-docker
│   │   └── init
│   └── v3-k8s
│       └── init
├── README.md
├── scripts
│   ├── v1-bigbang
│   │   ├── discord\_notify.sh
│   │   ├── kill\_process.sh
│   │   ├── restart\_servers.sh
│   │   ├── sftp\_uploads.sh
│   │   ├── show\_log.sh
│   │   └── start\_servers.sh
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
|----------|----------------|------|
| 전찬호   | `@jchanho99`   | ![jchanho99](https://github.com/jchanho99.png) |
| 이주미   | `@pieceofizzy` | ![pieceofizzy](https://github.com/pieceofizzy.png) |

> 🔽 GitHub 프로필 이미지는 위와 같이 자동 연결됩니다. 저장소 내 이미지로 대체할 경우, 경로를 수정하세요.

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

* `leafresh-fe-server-dev`
* `leafresh-be-db-prod`
* `leafresh-ai-model-gpu`

---

## 📌 기타 참고사항

* **`performance-test`**, **`scripts`**, **`terraform`** 디렉토리는 버전별로 (`v1-`, `v2-`, `v3-`) 관리됩니다.
* 주요 환경은 `v2-docker`, `v3-k8s` 기준으로 운영됩니다.

```

---

필요 시 `Badge`, `Architecture Diagram`, `버전 히스토리`, 또는 각 디렉토리별 설명도 추가할 수 있습니다. 추가 원하시면 알려주세요.
```

