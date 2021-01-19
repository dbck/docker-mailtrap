# Purpose

This image provides a simple catch all email server for development with smtp, imap and webmail support. The base image is debian and only default packages are used. **Only use this image for development purposes, because it is not designed to be secure. If it is connectable from the Internet, it can lead to an open relay mail server.**

# Inspired by

* [eaudeweb/mailtrap](https://github.com/eaudeweb/edw.docker.mailtrap)

# Performance & Improvements

This images uses dovecot as mda with sdbox as storage format, which delivers much more performance and stability than mbox with thousands of received mails. Also the image provides StartTLS / SSL with a selfsigned snakeoil certificate.

# Available Services/Ports

* SMTP Unsecure/StartTLS (25), SSL (465)
* Submission Unsecure/StartTLS (587)
* IMAP Unsecure/StartTLS (143), SSL (993)
* HTTP (80) -> Webmail [Roundcube](https://roundcube.net/)
  * `/api/inbox` -> Inbox messages as simple json objects.

# Environment variables with default values for customization

```
MAILTRAP_USER=mailtrap
MAILTRAP_PASSWORD=mailtrap
MAILTRAP_MAILBOX_LIMIT=51200000
MAILTRAP_MESSAGE_LIMIT=10240000
MAILTRAP_MAX_RECIPIENT_LIMIT=1000
```

# Starting a container

**Note:** The examples use the flag `--rm` to automatically remove the container instance, when stopped. The flag `--init` is required to speed up the shutdown of the container. Also the ports are bound to localhost.

## Simple container start

```
docker container run -d --rm --init --name=mailtrap -p 127.0.0.1:9080:80 -p 127.0.0.1:9025:25 dbck/mailtrap
```

## All ports mapped

```
docker container run -d --rm --init --name=mailtrap -p 127.0.0.1:9080:80 -p 127.0.0.1:9025:25 -p 127.0.0.1:9587:587 -p 127.0.0.1:9465:465 -p 127.0.0.1:9143:143 -p 127.0.0.1:9993:993 dbck/mailtrap
```

## Suggested port mapping

```
docker container run -d --rm --init --name=mailtrap -p 127.0.0.1:9080:80 -p 127.0.0.1:9025:25 -p 127.0.0.1:9587:587 -p 127.0.0.1:9143:143 dbck/mailtrap
docker logs -f mailtrap
```

## Example docker-compose configuration

Please look at [docker-compose.example.yml](https://github.com/dbck/docker-mailtrap/blob/main/docker-compose.example.yml)

# JSON API

The container provides a simple API under `/api/inbox` which returns a rudimentary view of messages received in the inbox. By calling `/api/inbox?flush=true` the received messages in the inbox will be flushed, after retrieval of the inbox as json.

```
[
    {
        "message_id": "<d083bf34a7a55e2049ae118feefc4b00@example.com>",
        "date": "Wed, 12 Jan 2021 20:14:55 +0100",
        "subject": "Hello from me",
        "from": [
            {
                "name": "Me",
                "address": "me@example.com"
            }
        ],
        "to": [
            {
                "name": "You",
                "address": "you@example.com"
            }
        ],
        "cc": [
            {
                "name": null,
                "address": "cc@example.com"
            }
        ],
        "reply_to": [
            {
                "name": null,
                "address": "reply-to@example.com"
            }
        ],
        "attachments": [
            {
                "filename": "Screenshot 2021-01-12 at 20.12.31.png"
            }
        ],
        "message": "   Hello You,\r\n\r\n   this is a test.\r\n\r\n   Cheers,\r\n   Me"
    }
]
```

# Send test mail while container is running

```
docker-compose exec -T mailtrap /bin/bash << EOF
telnet mailtrap 25
ehlo example.com
mail from: me@example.com
rcpt to: you@example.com
data
Subject: Hello from me
Hello You,

This is a test.

Cheers,
Me
.
quit
exit
EOF
```

# Development

## Build, develop and test image

```
export TAG=dev && docker-compose -f docker-compose.yml -f docker-compose.build.yml build && docker-compose up -d && docker-compose logs -f
```

```
export TAG=dev && docker-compose up
```

```
export TAG=dev && docker-compose down
```

## Build and push container image

```
export TAG=$(date +%Y%m%d-%H%M%S)
docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.build.latest.yml build
docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.build.latest.yml push
```