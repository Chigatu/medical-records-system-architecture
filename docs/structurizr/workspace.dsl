workspace {

    model {
        doctor = person "Врач" "Создает медицинские записи, просматривает историю пациентов"
        registrar = person "Регистратор" "Регистрирует новых пациентов в системе"
        admin = person "Администратор" "Управляет пользователями и системой"

        emailService = softwareSystem "Email-сервис" "Отправка email-уведомлений"
        smsService = softwareSystem "SMS-сервис" "Отправка SMS-оповещений"
        snilsService = softwareSystem "Сервис СНИЛС" "Проверка страховых номеров"

        medicalSystem = softwareSystem "Medical Records System" "Система управления медицинскими записями" {

            webApi = container "Web API" "REST API" "C++20, userver" "API"
            authService = container "Auth Service" "Аутентификация JWT" "C++20" "Service"
            patientService = container "Patient Service" "Управление пациентами" "C++20" "Service"
            recordService = container "Medical Record Service" "Управление записями" "C++20" "Service"
            eventProducer = container "Event Producer" "Публикация событий" "C++20, RabbitMQ" "Service"
            postgresDb = container "PostgreSQL" "Write-модель" "PostgreSQL 15" "Database"
            mongoDb = container "MongoDB" "Read-модель" "MongoDB 7" "Database"
            redisCache = container "Redis" "Кеширование" "Redis 7" "Cache"
            rabbitMq = container "RabbitMQ" "Брокер сообщений" "RabbitMQ 3" "Message Broker"
        }

        doctor -> medicalSystem "Создает записи, ищет пациентов" "HTTPS/REST"
        registrar -> medicalSystem "Регистрирует пациентов" "HTTPS/REST"
        admin -> medicalSystem "Управляет пользователями" "HTTPS/REST"
        medicalSystem -> emailService "Отправляет уведомления" "SMTP"
        medicalSystem -> smsService "Отправляет SMS" "HTTP/REST"
        medicalSystem -> snilsService "Проверяет СНИЛС" "HTTPS/REST"

        doctor -> webApi "HTTP-запросы" "HTTPS/REST"
        registrar -> webApi "HTTP-запросы" "HTTPS/REST"
        admin -> webApi "HTTP-запросы" "HTTPS/REST"

        webApi -> authService "Проверка JWT" "C++ call"
        webApi -> patientService "CRUD пациентов" "C++ call"
        webApi -> recordService "CRUD записей" "C++ call"

        authService -> postgresDb "Чтение/запись пользователей" "SQL/TCP"
        patientService -> postgresDb "Запись пациентов" "SQL/TCP"
        patientService -> mongoDb "Чтение пациентов" "MongoDB/TCP"
        recordService -> postgresDb "Запись записей" "SQL/TCP"
        recordService -> mongoDb "Чтение записей" "MongoDB/TCP"

        patientService -> redisCache "Кеш поиска" "Redis/TCP"
        recordService -> redisCache "Кеш истории" "Redis/TCP"
        authService -> redisCache "Rate limiting" "Redis/TCP"

        authService -> eventProducer "События пользователей" "In-memory"
        patientService -> eventProducer "События пациентов" "In-memory"
        recordService -> eventProducer "События записей" "In-memory"

        eventProducer -> rabbitMq "Публикация" "AMQP/TCP"
    }

    views {
        systemContext medicalSystem "SystemContext" { include * }
        container medicalSystem "Containers" { include * }

        dynamic medicalSystem "Dynamic-CreateMedicalRecord" {
            title "Сценарий: Создание медицинской записи"
            doctor -> webApi "1. POST /api/medical-records"
            webApi -> authService "2. Проверка JWT"
            authService -> postgresDb "3. Поиск пользователя"
            webApi -> recordService "4. Создание записи"
            recordService -> postgresDb "5. INSERT"
            recordService -> mongoDb "6. Синхронизация read"
            recordService -> redisCache "7. Инвалидация кеша"
            recordService -> eventProducer "8. Событие"
            eventProducer -> rabbitMq "9. MedicalRecordCreated"
        }
    }

    styles {
        element "Person" { shape person; background #08427b; color #ffffff }
        element "Software System" { background #1168bd; color #ffffff }
        element "Container" { background #438dd5; color #ffffff }
        element "Database" { shape cylinder; background #438dd5; color #ffffff }
        element "Cache" { shape cylinder; background #d54343; color #ffffff }
        element "Message Broker" { shape hexagon; background #d5a143; color #ffffff }
    }
}
