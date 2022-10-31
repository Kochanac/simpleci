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
- Об процессах уведомлять в телеграм бота
- При упавшем `docker-compose up` уведомлять в телеграм-бота (может в чате?)
- ? мб при упавшем контейнере тоже уведомлять

### Установка и конфигурация

Установка
```bash
git clone https://github.com/Kochanac/simpleci && cd simpleci;
make install
```

/etc/simpleci/
```yaml

# HARDCODED 15 update_rate: 15 # duration in seconds
repo_link: https://github.com/Kochanac/simpleci # valid git clone $link link
tg_bot:
	secret: <TG BOT SECRET>
	chat: 10x # substr in chat name

```
