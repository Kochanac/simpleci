INSTALL_DIR=/usr/local/bin
CONFIG=/etc/simpleci/config.yaml

tg_token = $$(niet tg_bot.tg_token $(CONFIG))
bot_chat_pass = $$(niet tg_bot.chat_register_password $(CONFIG))
webhook_register_pass = $$(niet tg_bot.webhook_send_password $(CONFIG))


config-bot:
	echo [] > /etc/tg_hook_chats.json
	chmod o+rw /etc/tg_hook_chats.json
	pip install -r src/bot-hook/requirements.txt

install: config-bot
	pip install niet

	cp src/simpleci.bash $(INSTALL_DIR)/simpleci
	chmod +x $(INSTALL_DIR)/simpleci

	mkdir /etc/simpleci
	cp ./config.yaml $(CONFIG)



run-tg-bot:
	echo $(tg_token)
	export BOT_TOKEN=$(tg_token); \
	export BOT_CHAT_PASSWORD=$(bot_chat_pass); \
	export BOT_WEBHOOK_PASSWORD=$(webhook_register_pass); \
	cd src/bot-hook/; \
	python3 bot.py & \
	uvicorn hook:app --port 10666
