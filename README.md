# Medical Records System — Архитектура (Structurizr DSL)

Документирование архитектуры системы управления медицинскими записями (Вариант 20, ДЗ №1).

## Диаграммы

Файл `docs/structurizr/workspace.dsl` содержит:

- **System Context (C1)** — система в контексте пользователей и внешних систем
- **Container (C2)** — контейнеры и их взаимодействие
- **Dynamic** — сценарий "Создание медицинской записи"

## Как посмотреть

### VS Code
1. Установите плагин **C4 Architect**
2. Откройте `docs/structurizr/workspace.dsl`
3. Правой кнопкой → "View C4 Diagrams"

### Structurizr Lite (Docker)
*```*
docker run -it --rm -p 8080:8080 \
  -v $(pwd)/docs/structurizr:/usr/local/structurizr \
  structurizr/lite
*```*
Откройте http://localhost:8080

## Роли пользователей

- **Врач** — создает медицинские записи, просматривает историю
- **Регистратор** — регистрирует пациентов
- **Администратор** — управляет пользователями

## Внешние системы

- **Email-сервис** — уведомления
- **SMS-сервис** — оповещения
- **Сервис СНИЛС** — проверка номеров

## Контейнеры

| Контейнер | Технология |
|-----------|------------|
| Web API | C++20, userver |
| Auth Service | C++20, JWT |
| Patient Service | C++20 |
| Medical Record Service | C++20 |
| Event Producer | C++20, RabbitMQ client |
| PostgreSQL | Write-модель |
| MongoDB | Read-модель |
| Redis | Кеш + Rate limiting |
| RabbitMQ | Брокер сообщений |
