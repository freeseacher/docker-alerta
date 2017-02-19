FROM alpine:latest

ENV ALERTA_SVR_CONF_FILE=/etc/alertad.conf \
    ALERTA_WEB_CONF_FILE=/app/config.js \
    BASE_URL=/api \
    PROVIDER=basic \
    CLIENT_ID=not-set \
    CLIENT_SECRET=not-set

RUN \
    echo http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && apk add --update python \
        py2-cffi \
        ca-certificates \
        openssl \
        uwsgi-python \
        py-pip \
        # using date for genertaion api key for heartbeat
        coreutils \
        # for installing key for heartbeat
        mongodb \
        # install plugins
        git \
    && apk --update add --virtual deps \
        build-base \
        gcc \
        python-dev \
        libffi-dev \
        wget \
        make \
    && pip install alerta-server alerta \
###
#  Fetch angular web
###
    && set -xe \
    && wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf - \
    && mv alerta-angular-alerta-webui-*/app /app \
    && rm -Rf /alerta-angular-alerta-webui-* \
    && mv /app/config.js /app/config.js.orig \
    && echo "from alerta.app import app" >/wsgi.py \
    && apk del deps

ADD uwsgi.ini /etc/uwsgi.ini
COPY /scripts/ /scripts/
COPY docker-entrypoint.sh /

VOLUME /app
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/uwsgi", "--ini", "/etc/uwsgi.ini"]
