from fastapi import FastAPI

import base64

from bot import *


app = FastAPI()

@app.get(f"/send/{WEBHOOK_PASSWORD}/{{message}}")
def webhookMessage(message):
	broadcast_message(message)
	return {"ok": True}


@app.get(f"/sendbase/{WEBHOOK_PASSWORD}/{{message}}")
def webhookMessage(message):
	broadcast_message(base64.b64decode(message))
	return {"ok": True}
