# Purpose

This image provides a simple catch all email server for development with smtp, imap and webmail support.
The base image is debian and only default packages are used.

** Only use this image for development purposes, because it is not designed to be secure. If it is connectable from the Internet, it can lead to an open relay mail server. **

# Available Services/Ports

* SMTP Unsecure/StartTLS (25), SSL (465), Submission Unsecure/StartTLS (587)
* IMAP Unsecure/StartTLS (143), SSL (993)
* HTTP (80) -> Roundcube

# Performance & Improvements

This images uses dovecot as mda with sdbox as storage format, which delivers much more performance and stability than mbox with thousands of received mails.
Also the image provides StartTLS / SSL with a selfsigned snakeoil certificate.

# Environment variables with default values for customization

* MAILTRAP_USER=mailtrap
* MAILTRAP_PASSWORD=mailtrap
* MAILTRAP_MAILBOX_LIMIT=51200000
* MAILTRAP_MESSAGE_LIMIT=10240000

# Simple container start

```
docker container run -d --name=mailtrap -p 9080:80 -p 9025:25 -p 9587:587 -p 9465:465 -p 9143:143 -p 9993:993 dbck/mailtrap
```

# Example docker-compose configuration

Please look at [docker-compose.example.yml](docker-compose.example.yml)

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

# Build, test and deploy container image

## Build image

```
export TAG=$(date +%Y%m%d-%H%M%S)
docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.build.latest.yml build
docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.build.latest.yml push
```

## Test image

```
docker-compose up
```

```
docker-compose down
```

## Build and test

```
export TAG=dev && docker-compose -f docker-compose.yml -f docker-compose.build.yml build && docker-compose up -d && docker-compose logs -f
```

# Inspired by

* eaudeweb/mailtrap - https://github.com/eaudeweb/edw.docker.mailtrap