Webhook hub
===========

Consumes various webhooks and fires others.

Docker
------
When the Docker Hub pushes a new image, post to Datadog an Hipchat and then callback the hub.

Hipchat
-------
When a room message fires, CC the message to Slack

Hipchat webhooks are configured like
```shell
curl 'api.hipchat.com/v2/room/${ROOMNAME}/webhook?auth_token=${AUTH_TOKEN}' -XPOST -H 'content-type: application/json' -d '{"url":"${HOOK_URL}","pattern":".*","event":"room_message","name":"${HOOK_NAME}"}'
```


Environment variables to set
----------------------------
- DATADOG_API_KEY
- HIPCHAT_AUTH_TOKEN
- HIPCHAT_ROOM
- HIPCHAT_SENDER_NAME
- SLACK_HOOK_URL
