#!/bin/bash

echo "Waiting for Postfix..."

while ! (echo > /dev/tcp/127.0.0.1/25) >/dev/null 2>&1; do
  sleep 1
done

echo "Postfix is up - starting Dovecot"
exec /usr/sbin/dovecot -F