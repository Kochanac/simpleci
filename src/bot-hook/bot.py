import time, json
from os import environ
from secrets import token_hex

import requests as req


TOKEN = environ.get("BOT_TOKEN", None)

if not TOKEN:
	print("NO TELEGRAM TOKEN")
	exit(1)

CHAT_PASSWORD = str(environ.get("BOT_CHAT_PASSWORD", token_hex()))
WEBHOOK_PASSWORD = str(environ.get("BOT_WEBHOOK_PASSWORD", token_hex()))


print(f"{CHAT_PASSWORD = }\n{WEBHOOK_PASSWORD = }")

pool_time = 2 # seconds

api = f"https://api.telegram.org/bot{TOKEN}/"

def send_message(chat_id, text, fmt="MarkdownV2"):
	data = {"chat_id": chat_id, "text": text}
	if fmt != "plain":
		data["parse_mode"] = fmt

	resp = req.post(api + "sendMessage", data=data)

	if resp.json()["ok"] != True:
		raise Exception(resp.text)

def register_chat_id(chat_id):
	try:
		with open("/etc/tg_hook_chats.json", "r") as chats_file:
			chats = json.load(chats_file)
	except FileNotFoundError:
		chats = []

	chats.append(chat_id)
	chats = list(set(chats))

	with open("/etc/tg_hook_chats.json", "w") as chats_file:
		json.dump(chats, chats_file)


def get_chats():
	try:
		with open("/etc/tg_hook_chats.json", "r") as chats_file:
			chats = json.load(chats_file)
	except FileNotFoundError:
		chats = []
	return chats


def broadcast_message(message):
	for chat in get_chats():
		print(f"sending {message} to {chat = }")
		send_message(chat, message)


def handle_update(request: "json"):
	chat_id = request["message"]["chat"]["id"]
	text = request["message"]["text"]

	if CHAT_PASSWORD in text:
		send_message(chat_id, f"registered chat_id {chat_id}", fmt="plain")
		register_chat_id(chat_id)


def pull_updates():
	try:
		with open("/tmp/commited_updates", "r") as commit:
			last_update = int(commit.read())
	except FileNotFoundError:
		last_update = 0

	upds = req.post(api + "getUpdates", data={"offset": last_update + 1, "allowed_updates": "message"}).json()
	
	max_id = 0
	for upd in upds["result"]:
		try:
			print(upd)
			handle_update(upd)
		except Exception as e:
			print("EXCEPTION:", e)
		max_id = max(max_id, upd["update_id"])

	with open("/tmp/commited_updates", "w") as commit:
		commit.write(str(max_id))


if __name__ == '__main__':
	while True:
		pull_updates()
		time.sleep(pool_time)

