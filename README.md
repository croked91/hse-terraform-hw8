# Домашняя работа №8: Работа с Terraform

Terraform конфигурация для развертывания веб-приложения в Yandex Cloud.

## Инфраструктура

- VPC сеть и подсеть с Security Group
- Виртуальная машина с публичным IP и nginx
- PostgreSQL кластер
- S3 объектное хранилище
- Сервисный аккаунт с ролью storage.editor

## Развертывание

1. Настройте переменные окружения:

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

**Альтернативный способ**: Вместо использования переменных окружения YC_*, вы можете:
- Использовать переменную окружения: `export TF_VAR_folder_id="your-folder-id"`

2. Инициализируйте и примените конфигурацию:

```bash
terraform init
terraform plan
terraform apply
```

3. Получите URL веб-сайта:

```bash
terraform output website_url
```

## Удаление

```bash
terraform destroy
```

