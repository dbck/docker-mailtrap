# Purpose

This image provides a simple catch all email server for development with smtp, imap and webmail support. The base image is debian and only default packages are used. **Only use this image for development purposes, because it is not designed to be secure. If it is connectable from the Internet, it can lead to an open relay mail server.**

# Inspired by

* eaudeweb/mailtrap - https://github.com/eaudeweb/edw.docker.mailtrap

# Performance & Improvements

This images uses dovecot as mda with sdbox as storage format, which delivers much more performance and stability than mbox with thousands of received mails. Also the image provides StartTLS / SSL with a selfsigned snakeoil certificate.

# Available Services/Ports

* SMTP Unsecure/StartTLS (25), SSL (465)
* Submission Unsecure/StartTLS (587)
* IMAP Unsecure/StartTLS (143), SSL (993)
* HTTP (80) -> Webmail/Roundcube

# Environment variables with default values for customization

```
MAILTRAP_USER=mailtrap
MAILTRAP_PASSWORD=mailtrap
MAILTRAP_MAILBOX_LIMIT=51200000
MAILTRAP_MESSAGE_LIMIT=10240000
```

# Starting a container

**Note:** The examples use the flag `--rm` to automatically remove the container instance, when stopped. The flag `--init is required to speed up the shutdown of the container. Also the ports are bound to localhost.

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

# Send test mail while container is running

```
docker-compose exec mailtrap /bin/bash
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