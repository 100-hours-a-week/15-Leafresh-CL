output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_app_subnet_id" {
  value = module.network.private_app_subnet_id
}

output "private_db_subnet_id" {
  value = module.network.private_db_subnet_id
}

output "nextjs_public_ip" {
  value = module.compute.nextjs_instance_ip
}

output "springboot_private_ip" {
  value = module.compute.springboot_instance_private_ip
}

output "mysql_private_ip" {
  value = module.sql.mysql_private_ip
}

output "redis_private_ip" {
  value = module.redis.redis_private_ip
}

output "redis_port" {
  value = module.redis.redis_port
}
