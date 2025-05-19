resource "google_sql_database_instance" "mysql" {
  name             = var.mysql_instance_name
  project          = var.project_id
  region           = var.region
  database_version = "MYSQL_8_0" # 필요에 따라 버전 변경
  settings {
    tier = "db-f1-micro" # 필요에 따라 서비스 등급 변경
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_db_subnet_id
    }
  }
  deletion_protection  = false # 실제 운영 환경에서는 true로 설정 권장
  tags                 = merge(var.tags, {"tier" : "database", "app" : "mysql"})
}

output "mysql_private_ip" {
  value = google_sql_database_instance.mysql.private_ip_address
}
