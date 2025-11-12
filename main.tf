# Local values для вычисляемых имен
locals {
  vpc_network_name     = "${var.name_prefix}-network"
  vpc_subnet_name      = "${var.name_prefix}-subnet"
  security_group_name  = "${var.name_prefix}-sg"
  vm_name              = "${var.name_prefix}-vm"
  postgresql_name      = "${var.name_prefix}-postgresql"
  service_account_name = "${var.name_prefix}-sa"
  bucket_name          = "${var.name_prefix}-bucket-${random_string.bucket_suffix.result}"
}

# Генерация случайной строки для уникальности имени bucket
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Создание VPC сети
resource "yandex_vpc_network" "this" {
  name = local.vpc_network_name
}

# Создание подсети
resource "yandex_vpc_subnet" "this" {
  name           = local.vpc_subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.vpc_subnet_cidr]
}

# Создание Security Group для VM
resource "yandex_vpc_security_group" "vm" {
  name        = local.security_group_name
  description = "Security group for web server VM"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "HTTP"
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS"
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "SSH"
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Создание сервисного аккаунта
resource "yandex_iam_service_account" "sa" {
  name        = local.service_account_name
  description = "Service account for S3 bucket access"
}

# Назначение роли storage.editor сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создание статического ключа доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "sa_key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Static access key for S3 bucket"
}

# Создание загрузочного диска для VM
resource "yandex_compute_disk" "boot_disk" {
  name     = "${local.vm_name}-boot-disk"
  zone     = var.zone
  image_id = var.image_id
  type     = try(var.vm_resources.disk.disk_type, "network-ssd")
  size     = try(var.vm_resources.disk.disk_size, 20)
}

# Cloud-init скрипт для установки nginx и развертывания сайта
# Используем файлы из директории web/ вместо дублирования контента
locals {
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tpl", {
    index_html = base64encode(file("${path.module}/web/index.html"))
    style_css  = base64encode(file("${path.module}/web/style.css"))
    script_js  = base64encode(file("${path.module}/web/script.js"))
  })
}

# Создание виртуальной машины с публичным IP
resource "yandex_compute_instance" "vm" {
  name                      = local.vm_name
  zone                      = var.zone
  platform_id               = try(var.vm_resources.platform_id, "standard-v3")
  allow_stopping_for_update = true

  resources {
    cores  = var.vm_resources.cores
    memory = var.vm_resources.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.this.id
    security_group_ids = [yandex_vpc_security_group.vm.id]
    nat                = true # Публичный IP
  }

  metadata = {
    user-data = local.cloud_init
  }
}

# Создание S3 bucket
resource "yandex_storage_bucket" "this" {
  bucket     = local.bucket_name
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key

  max_size = try(var.bucket_config.max_size, 1073741824)

  depends_on = [yandex_resourcemanager_folder_iam_member.storage_editor]
}

# Загрузка HTML файла в bucket
resource "yandex_storage_object" "index_html" {
  bucket     = yandex_storage_bucket.this.bucket
  key        = "index.html"
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key
  content    = file("${path.module}/web/index.html")
  acl        = "public-read"
}

# Загрузка CSS файла в bucket
resource "yandex_storage_object" "style_css" {
  bucket     = yandex_storage_bucket.this.bucket
  key        = "style.css"
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key
  content    = file("${path.module}/web/style.css")
  acl        = "public-read"
}

# Загрузка JS файла в bucket
resource "yandex_storage_object" "script_js" {
  bucket     = yandex_storage_bucket.this.bucket
  key        = "script.js"
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key
  content    = file("${path.module}/web/script.js")
  acl        = "public-read"
}

# Создание PostgreSQL кластера
resource "yandex_mdb_postgresql_cluster" "this" {
  name        = local.postgresql_name
  description = "PostgreSQL cluster for application"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.this.id

  config {
    version = var.postgresql_config.version
    resources {
      resource_preset_id = try(var.postgresql_config.resources.resource_preset_id, "s2.micro")
      disk_size          = try(var.postgresql_config.resources.disk_size, 10)
      disk_type_id       = try(var.postgresql_config.resources.disk_type_id, "network-ssd")
    }
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.this.id
  }

  depends_on = [yandex_vpc_subnet.this]
}

# Создание пользователя PostgreSQL
resource "yandex_mdb_postgresql_user" "this" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = var.postgresql_config.database_user
  password   = var.postgresql_config.database_password
}

# Создание базы данных PostgreSQL
resource "yandex_mdb_postgresql_database" "this" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = var.postgresql_config.database_name
  owner      = yandex_mdb_postgresql_user.this.name

  depends_on = [yandex_mdb_postgresql_user.this]
}

