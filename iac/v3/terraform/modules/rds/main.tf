# modules/rds/main.tf

locals {
  db_identifier_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
  }, var.additional_tags)
}

# 1. RDS DB 서브넷 그룹 생성
# RDS 인스턴스가 배포될 서브넷들을 지정합니다.
# 일반적으로 Private Subnet에 배치하여 외부 접근을 차단합니다.
resource "aws_db_subnet_group" "main" {
  name       = "${local.db_identifier_prefix}-subnet-group"
  subnet_ids = var.database_subnet_ids # 루트 모듈에서 전달받은 DB 서브넷 ID 목록

  tags = merge(local.common_tags, {
    Name = "${local.db_identifier_prefix}-db-subnet-group"
  })
}

# 2. RDS DB 인스턴스 생성
resource "aws_db_instance" "main" {
  identifier           = "${local.db_identifier_prefix}-db-instance"
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  storage_encrypted    = var.db_storage_encrypted # 저장 시 암호화
  publicly_accessible  = false # 반드시 false로 설정하여 퍼블릭 접근 차단
  multi_az             = var.db_multi_az # 고가용성 구성 여부

  db_name              = var.db_name # 초기 생성될 데이터베이스 이름
  username             = var.db_username
  password             = var.db_password
  port                 = var.db_port

  vpc_security_group_ids = [var.database_security_group_id] # 루트 모듈에서 전달받은 DB 보안 그룹 ID
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = var.db_skip_final_snapshot # 프로덕션 환경에서는 false 권장
  backup_retention_period = var.db_backup_retention_period # 백업 보존 기간
  copy_tags_to_snapshot = true # 스냅샷에 태그 복사

  # 파라미터 그룹 (선택 사항, 필요 시 추가)
  # parameter_group_name = "default.postgres14"

  # 백업 윈도우 (선택 사항)
  # backup_window        = "03:00-05:00"

  # 유지보수 윈도우 (선택 사항)
  # maintenance_window   = "Mon:05:00-Mon:06:00"

  tags = merge(local.common_tags, {
    Name = "${local.db_identifier_prefix}-db-instance"
  })
}
