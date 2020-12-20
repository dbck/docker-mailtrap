ARG FROM_IMAGE
FROM $FROM_IMAGE

LABEL maintainer "Dennis Boeckmann <dev@dbck.de>"
LABEL description "Debian based simple mailtrap container for development purposes"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -q -y install \
    wget \
    telnet \
    ssl-cert \
    nginx \
    postfix \
    dovecot-imapd \
    sqlite \
    php \
    php-fpm \
    php-mbstring \
    php-sqlite3 \
    php7.3-imap \
    php7.3-zip \
    php-pear \
    roundcube \
    roundcube-sqlite3 \
    roundcube-plugins \
    roundcube-plugins-extra \
    rsyslog \
    vim \
    && rm -rf /var/lib/apt/lists/*

ENV MAILTRAP_USER mailtrap
ENV MAILTRAP_PASSWD mailtrap
ENV MAILTRAP_MAILBOX_LIMIT 51200000
ENV MAILTRAP_MESSAGE_LIMIT 10240000

# Postfix
COPY root/etc/postfix/* /etc/postfix/

# Dovecot
COPY root/etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf

# NGINX
COPY root/etc/nginx/sites-available/roundcube /etc/nginx/sites-available/
RUN rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/roundcube /etc/nginx/sites-enabled/roundcube

# Roundcube
COPY root/etc/roundcube/config.inc.php etc/roundcube/config.inc.php
RUN mkdir -p /var/lib/roundcube/db && \
    sqlite3 -init /usr/share/roundcube/SQL/sqlite.initial.sql /var/lib/roundcube/db/sqlite.db && \
    chmod 775 -R /var/lib/roundcube/db && \
    chown -R www-data:www-data /var/lib/roundcube/db

COPY root/docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh

EXPOSE 25 80 465 587 143 993

ENTRYPOINT ["/docker-entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=5s CMD curl -f http://127.0.0.1 || exit 1