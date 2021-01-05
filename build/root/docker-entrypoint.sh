#!/usr/bin/env bash

# Setup roundcube des_key
RC_DES_KEY=`cat /dev/urandom | head -n 256 | sha256sum | awk '{print $1}'`;
sed -i "s/###DES_KEY###/$RC_DES_KEY/" /etc/roundcube/config.inc.php

# generate new certificate
make-ssl-cert generate-default-snakeoil --force-overwrite

# generate dovecote userdb
echo -n "$MAILTRAP_USER:" > /etc/dovecot/passwd.db
doveadm pw -s SHA512-CRYPT >> /etc/dovecot/passwd.db <<EOF
${MAILTRAP_PASSWORD}
${MAILTRAP_PASSWORD}
EOF

# Set parameters in postfix config
sed -i "s/###MAILTRAP_MAILBOX_LIMIT###/$MAILTRAP_MAILBOX_LIMIT/" /etc/postfix/main.cf
sed -i "s/###MAILTRAP_MESSAGE_LIMIT###/$MAILTRAP_MESSAGE_LIMIT/" /etc/postfix/main.cf
sed -i "s/###MAILTRAP_MAX_RECIPIENT_LIMIT###/$MAILTRAP_MAX_RECIPIENT_LIMIT/" /etc/postfix/main.cf

# Configure services and transports in master.cf
sed -i "s/#submission inet n       -       y       -       -       smtpd/submission inet n       -       y       -       -       smtpd/" /etc/postfix/master.cf
echo -e "dovecot unix - n n - - pipe flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -f \${sender} -d ${MAILTRAP_USER}" >> /etc/postfix/master.cf

# Generate aliases and transport map
newaliases
postmap /etc/postfix/transport

# Start services
service rsyslog start
service dovecot start
service postfix start
mkdir -p /run/php
service php7.3-fpm start
service nginx start

touch /var/log/mail.err && tail -f /var/log/mail.err /var/log/mail.log