INSTALL_DIR=/usr/local/bin
CONFIG=/etc/simpleci/config.yaml

tg_token = $$(niet tg_bot.tg_token $(CONFIG))
bot_chat_pass = $$(niet tg_bot.chat_register_password $(CONFIG))
webhook_register_pass = $$(niet tg_bot.webhook_send_password $(CONFIG))


config-bot:
	echo [] > /etc/tg_hook_chats.json
	chmod o+rw /etc/tg_hook_chats.json


install-ubuntu: config-bot
	apt update
	apt install -y python3 python3-pip

	pip install niet
	pip install -r src/bot-hook/requirements.txt

	cp src/simpleci.bash $(INSTALL_DIR)/simpleci
	chmod +x $(INSTALL_DIR)/simpleci

	cp src/format_tg_config.bash $(INSTALL_DIR)/format_tg_config
	chmod +x $(INSTALL_DIR)/format_tg_config

	mkdir -p /etc/simpleci
	cp ./config.yaml $(CONFIG)

	mkdir -p /opt/simpleci

	cp -r src/bot-hook /opt/simpleci/bot

	echo $$(whereis python3)
	echo $$(whereis uvicorn)

	cat src/services/bot_bot.service | format_tg_config > /etc/systemd/system/simpleci_bot.service
	cat src/services/bot_hook.service | format_tg_config > /etc/systemd/system/simpleci_tg_hook_service.service

	cp src/services/simpleci* /etc/systemd/system/

	systemctl start simpleci_bot.service
	systemctl start simpleci_tg_hook_service.service
	systemctl start simpleci.service
	systemctl start simpleci.timer

	systemctl enable simpleci_bot.service
	systemctl enable simpleci_tg_hook_service.service
	systemctl enable simpleci.service
	systemctl enable simpleci.timer


test-run-tg-bot:
	echo $(tg_token)
	export BOT_TOKEN=$(tg_token); \
	export BOT_CHAT_PASSWORD=$(bot_chat_pass); \
	export BOT_WEBHOOK_PASSWORD=$(webhook_register_pass); \
	cd src/bot-hook/; \
	python3 bot.py & \
	uvicorn hook:app --port 10666
