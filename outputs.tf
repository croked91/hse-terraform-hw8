output "vpc_network_id" {
  description = "ID созданной VPC сети"
  value       = yandex_vpc_network.this.id
}

output "vpc_subnet_id" {
  description = "ID созданной подсети"
  value       = yandex_vpc_subnet.this.id
}

output "vm_id" {
  description = "ID созданной виртуальной машины"
  value       = yandex_compute_instance.vm.id
}

output "vm_public_ip" {
  description = "Публичный IP адрес виртуальной машины"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "vm_private_ip" {
  description = "Приватный IP адрес виртуальной машины"
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "website_url" {
  description = "URL веб-сайта"
  value       = "http://${yandex_compute_instance.vm.network_interface[0].nat_ip_address}"
}

output "postgresql_cluster_id" {
  description = "ID PostgreSQL кластера"
  value       = yandex_mdb_postgresql_cluster.this.id
}

output "postgresql_host" {
  description = "Хост PostgreSQL кластера"
  value       = yandex_mdb_postgresql_cluster.this.host[0].fqdn
}

output "postgresql_database" {
  description = "Имя базы данных PostgreSQL"
  value       = var.postgresql_config.database_name
  sensitive   = true
}

output "postgresql_user" {
  description = "Имя пользователя PostgreSQL"
  value       = var.postgresql_config.database_user
  sensitive   = true
}

output "postgresql_password" {
  description = "Пароль пользователя PostgreSQL"
  value       = var.postgresql_config.database_password
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Имя S3 bucket"
  value       = yandex_storage_bucket.this.bucket
}

output "s3_bucket_domain" {
  description = "Доменное имя S3 bucket"
  value       = yandex_storage_bucket.this.bucket_domain_name
}

output "service_account_id" {
  description = "ID сервисного аккаунта"
  value       = yandex_iam_service_account.sa.id
}

output "service_account_access_key" {
  description = "Access key для доступа к S3"
  value       = yandex_iam_service_account_static_access_key.sa_key.access_key
  sensitive   = true
}

output "service_account_secret_key" {
  description = "Secret key для доступа к S3"
  value       = yandex_iam_service_account_static_access_key.sa_key.secret_key
  sensitive   = true
}
