variable "name_prefix" {
  description = "Префикс имени для всех ресурсов проекта"
  type        = string
  default     = "hw8-app"
}

variable "folder_id" {
  description = "ID папки Yandex Cloud, где будут созданы ресурсы. Может быть задан через переменную окружения YC_FOLDER_ID или TF_VAR_folder_id"
  type        = string
  default     = null
}

variable "zone" {
  description = "Зона Yandex Cloud для размещения ресурсов"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "ID образа для загрузочного диска VM. По умолчанию Ubuntu 22.04 LTS"
  type        = string
  default     = "fd8ba9d5mfvlncknt2kd"
}

variable "vm_resources" {
  description = "Ресурсы для виртуальной машины"
  type = object({
    platform_id = optional(string, "standard-v3")
    cores       = number
    memory      = number
    disk = optional(object({
      disk_type = optional(string, "network-ssd")
      disk_size = optional(number, 20)
    }), {})
  })
  default = {
    cores  = 2
    memory = 4
  }
}

variable "vpc_subnet_cidr" {
  description = "CIDR блок для подсети VPC"
  type        = string
  default     = "192.168.10.0/24"
}

variable "postgresql_config" {
  description = "Конфигурация PostgreSQL кластера"
  type = object({
    version = optional(string, "15")
    resources = object({
      resource_preset_id = optional(string, "s2.micro")
      disk_size          = optional(number, 10)
      disk_type_id       = optional(string, "network-ssd")
    })
    database_name     = optional(string, "appdb")
    database_user     = optional(string, "appuser")
    database_password = string
  })
  sensitive = true
}

variable "bucket_config" {
  description = "Конфигурация S3 bucket"
  type = object({
    max_size = optional(number, 1073741824) # 1GB в байтах
  })
  default = {}
}

