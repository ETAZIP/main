# Momo Store aka Пельменная №2

<img width="900" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

## Для локального тестирования

 Frontend

```bash
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```

 Backend

```bash
go run ./cmd/api
go test -v ./... 
```

## Пельмени можно прикупить тут https://momo.provadm.space/


## Структура репозитория

- Все расположено в одном репозитории.
- Каталоги backend/frontend содержат ci pipelines, которые запускаются триггерами из корня проекта, при внесении измнений в любой из них.
- В репе имеются Dockerfile для docker image, helm чарты, а так же стандартые манифесты, деплой и сборка происходит через helm


## Описанные pipeline делают следующее:

- SAST тестирование кода и отправка результатов в  sonarqube
- Сборка приложения в докер образ.
- Пуш образа в репозиторий 
- Сборка helm чарта с использованием актуального docker image (Собранного в рамках pipeline)
- Релиз helm чарта в nexus repository 
- Деплой приложения в облачный k8s кластер YC, в нейм спейс momo-project

---

Описание процесса:

Версионированние происходит через переменную VERSION, которая подставляет к версии приложение (1.0.х) ID pipeline.
После публикации нового образа в Gitlab container registry, ему добавляется версия 1.0.CI_PIPELINE_ID из переменной $VERSION.

1. Запускается тестирование, передает данные в Sonarqube
2. Запускается сборка образа и пуш его в реп.
3. Запускается сборка пакета helm, через sed вносятся изменение в файлы Chart и values, меняя образ (frontend/backend), версию чарта и версию приложения в чарте.
4. Запускается релиз чарта в Nexus с тегом $VERSION.
5. Запускается деплой релиза в k8s кластер.

...

## Инфраструктура 


<img width="900" alt="image" src="https://storage.yandexcloud.net/momo-bucket/infra.jpg">

Инфраструктура состоит из:

- Kubernetes as Service  и 2 ноды.
- ALB для ingress.
- Домен provadm.space
- Wildcard сертификат на весь домен *.provadm.space
- S3 bucket для картинок пельменной


