#!/usr/bin/env bash

# setup roundcube des_key
RC_DES_KEY=`cat /dev/urandom | head -n 256 | sha256sum | awk '{print $1}'`;
sed -i "s/###DES_KEY###/$RC_DES_KEY/" /etc/roundcube/config.inc.php

make-ssl-cert generate-default-snakeoil --force-overwrite

echo -n "$MAILTRAP_USER@example.com:" > /etc/dovecot/passwd.db
doveadm pw -s SHA512-CRYPT >> /etc/dovecot/passwd.db <<EOF
${MAILTRAP_PASSWORD}
${MAILTRAP_PASSWORD}
EOF

sed -i "s/###MAILTRAP_MAILBOX_LIMIT###/$MAILTRAP_MAILBOX_LIMIT/" /etc/postfix/main.cf
sed -i "s/###MAILTRAP_MESSAGE_LIMIT###/$MAILTRAP_MESSAGE_LIMIT/" /etc/postfix/main.cf
sed -i "s/#submission inet n       -       y       -       -       smtpd/submission inet n       -       y       -       -       smtpd/" /etc/postfix/master.cf
newaliases
postmap /etc/postfix/canonical
postmap /etc/postfix/virtual-mailbox-domains
postmap /etc/postfix/virtual-mailbox-users
postmap /etc/postfix/virtual
postmap /etc/postfix/match_all_destination_re

service postgresql start
sudo -u postgres /bin/bash -c "psql -c \"CREATE ROLE roundcube WITH LOGIN PASSWORD 'roundcube';\""
sudo -u postgres /bin/bash -c 'psql -c "CREATE DATABASE roundcube WITH OWNER roundcube ENCODING UTF8;"'
sudo -u postgres /bin/bash -c 'export PGHOST=localhost PGPORT=5432 PGUSER=roundcube PGPASSWORD=roundcube && psql -U roundcube -h localhost -f /usr/share/roundcube/SQL/postgres.initial.sql roundcube'

service rsyslog start
service dovecot start
service postfix start
mkdir -p /run/php
service php7.3-fpm start
service nginx start

touch /var/log/mail.err
#tail -f /var/log/syslog -f /var/log/mail.log -f /var/log/nginx/*.log -f /var/log/php7.3-fpm.log -f /var/log/php
tail -f /var/log/mail.err