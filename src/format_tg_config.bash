#!/bin/bash

[[ -z $CONFIG_PATH ]] && CONFIG_PATH="/etc/simpleci/config.yaml"

sed "s|%PYTHON3%|$(whereis python3 | cut -d' ' -f2)|" |
sed "s|%uvicorn%|$(whereis uvicorn | cut -d' ' -f2)|" |

sed "s|%bot_token%|$(niet tg_bot.tg_token $CONFIG_PATH)|" |
sed "s|%bot_chat_password%|$(niet tg_bot.chat_register_password $CONFIG_PATH)|" |
sed "s|%bot_webhook_password%|$(niet tg_bot.webhook_send_password $CONFIG_PATH)|"
