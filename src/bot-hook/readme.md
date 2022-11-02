## Telegram webhook hooker bot

Когда-нибудь хотели пайпить в чат в телеграме?

1. run:
```
pip install -r requirements.txt

export BOT_TOKEN="..."

python3 bot.py &
uvicorn hook:app --port 10666
```

2. send chat_password of the bot to any chat

3. usage:
```
curl "http://localhost:10666/sendbase/PASSWORD/$(echo '🧐🧐🧐 service is *down*' | base64)"
```
