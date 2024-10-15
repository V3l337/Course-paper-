terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84"  # Укажите версию провайдера
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandexT 
  folder_id = var.yandexIDF
  #zone      = var.YaZone
}
