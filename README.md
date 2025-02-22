# Балансировка веб-приложения

## Задание

Развернуть 4 виртуальные машины терраформом в Яндекс.Облаке:

- Одна виртуальная машина балансировщик с публичным IP адресом. Показать конфигурацию для балансировки методами **round-robin** и **hash**.
- Две виртуальные машины **nginx frontend** со статикой и **backend** на выбор.
- Запустить виртуальную машину с одним экземпляром базы данных для работы с **backend**.

## Реализация

Скрипт состоит из нескольких файлов:

- [terraform.tf](terraform.tf) - содержит список используемых провайдеров и их версии;
- [providers.tf](providers.tf) - содержит настройки провайдера **Yandex Cloud**;
- [variables.tf](variables.tf) - содержит описания используемых переменных;
- [outputs.tf](outputs.tf) - содержит код, возвращающий IP адреса создаваемых машин;
- [main.tf](main.tf) - содержит описания создаваемых машин.

Также написаны шаблоны:

- [cloud-config.tftpl](cloud-config.tftpl) - конфигурация **cloud init** для создаваемых машин;
- [inventory.tftpl](inventory.tftpl) - шаблон инвентартного файла `inventory.yml` для **ansible**;

Помимо этого написаны скрпипты для автоматизации запуска:

- [update-tfvars.sh](update-tfvars.sh) - генерирует SSH ключ `secrets/yandex-cloud` для подключения к машине создаёт файл секретов `terraform.tfvars` на основании переменных, указанных в скрипте:
- [provision.sh](provision.sh) - запускает `ansible-playbook provision.yml`;
- [up.sh](up.sh) - выполняет все действия, необходимые для создания и настройки машины:

Файл `provision.yml` в свою очередь запускает роли:

- **wait_connection** - ожидает доступности машин.

Общие переменные для **ansible** находятся в [group_vars/all.yml](group_vars/all.yml).

## Запуск

1. Необходимо установить и настроить утилиту **yc** по инструкции [Начало работы с интерфейсом командной строки](https://yandex.cloud/ru/docs/cli/quickstart).
2. Необходимо установить **Terraform** по инструкции [Начало работы с Terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart).
3. Необходимо установить **Ansible**.
4. Необходимо перейти в папку проекта и запустить скрипт [up.sh](up.sh).

Протестировано в **OpenSUSE Tumbleweed**:

- **Ansible 2.18.2**
- **Python 3.11.11**
- **Jinja2 3.1.5**

## Проверка
