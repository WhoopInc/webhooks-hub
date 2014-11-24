Webhook hub
===========

Consumes various webhooks and fires others.

Docker
------
When the Docker Hub pushes a new image, post to Datadog and then callback the hub.



Environment variables to set
----------------------------
- DATADOG_API_KEY
- HIPCHAT_AUTH_TOKEN
- HIPCHAT_ROOM
- HIPCHAT_SENDER_NAME
