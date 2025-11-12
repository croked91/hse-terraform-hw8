# Объявление провайдеров
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  required_version = ">= 1.0"
}

provider "yandex" {
  folder_id = var.folder_id # Если null, провайдер использует YC_FOLDER_ID из окружения
  zone      = var.zone
}

provider "random" {
}

