# Simple CI

Скрипты на баше которые должны делать процесс обновления кода в сервисах очень простым. 

### Использование

```bash
git clone <private_git_repo_with_tasks>
cd task_1
# <editing>
git commit -m 'any message'
git push # -> master
```

После этого скрипты автоматически запускают `docker-compose up --build` в измененном сервисе.
- Об процессах уведомлять в телеграм
- При упавшем `docker-compose up` уведомлять в телеграм
- Если `docker-compose up` падает, то пытаться откатиться на одну версию вниз и ребилднуть её
- TODO: При упавшем контейнере тоже уведомлять

### Установка и конфигурация

Установка
```bash
git clone https://github.com/Kochanac/simpleci && cd simpleci;
# edit config.yaml
make install
```

/etc/simpleci/config.yaml
```yaml

# HARDCODED 5 update_rate: 5 # duration in seconds
repo_link: https://github.com/Kochanac/simpleci # valid git clone $link link
clone_path: /home/services/
tg_bot:
  tg_token: <TG-BOT-SECRET>
  chat_register_password: loxlox
  webhook_send_password: suk

```
