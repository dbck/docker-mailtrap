#!/usr/bin/env bash

# setup roundcube des_key
RC_DES_KEY=`cat /dev/urandom | head -n 256 | sha256sum | awk '{print $1}'`;
sed -i "s/###DES_KEY###/$RC_DES_KEY/" /etc/roundcube/config.inc.php

make-ssl-cert generate-default-snakeoil --force-overwrite
useradd -u 1000 -m -s /bin/bash $MAILTRAP_USER && echo "$MAILTRAP_USER:$MAILTRAP_PASSWD" | chpasswd
usermod -a -G mail $MAILTRAP_USER
sed -i "s/#disable_plaintext_auth = yes/disable_plaintext_auth = no/" /etc/dovecot/conf.d/10-auth.conf
sed -i "s/###MAILTRAP_USER###/$MAILTRAP_USER/" /etc/postfix/transport
sed -i "s/###MAILTRAP_USER###/$MAILTRAP_USER/" /etc/postfix/main.cf
sed -i "s/###MAILTRAP_MAILBOX_LIMIT###/$MAILTRAP_MAILBOX_LIMIT/" /etc/postfix/main.cf
sed -i "s/###MAILTRAP_MESSAGE_LIMIT###/$MAILTRAP_MESSAGE_LIMIT/" /etc/postfix/main.cf
sed -i "s/#submission inet n       -       y       -       -       smtpd/submission inet n       -       y       -       -       smtpd/" /etc/postfix/master.cf
postmap /etc/postfix/transport

service rsyslog start
service dovecot start
service postfix start
mkdir -p /run/php
service php7.3-fpm start
service nginx start

tail -f /var/log/syslog -f /var/log/mail.log -f /var/log/nginx/*.log -f /var/log/php7.3-fpm.log -f /var/log/php