# provider.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.35.0"
    }
  }
}

provider "google" {
  project = "leafresh"        # 여기에 실제 GCP 프로젝트 ID를 입력하세요.
  region  = "asia-northeast3" # 서울 리전으로 설정
}
