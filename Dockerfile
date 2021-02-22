
FROM alpine:3.13.2

ENV PATH /usr/local/bin:$PATH

ENV LANG C.UTF-8

ENV SHELL /bin/bash

RUN sed -i 's@dl-cdn.alpinelinux.org@mirrors.aliyun.com@g' /etc/apk/repositories


RUN \
    apk update && apk add --no-cache openrc htop curl bash ca-certificates nginx python3 py3-pip; \
    python3 -m pip install --upgrade pip && python3 -m pip install -U wheel; \
    mkdir -p ~/.pip/&& touch ~/.pip/pip.conf && \
    echo "[global] " > ~/.pip/pip.conf && \
    echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf && \
    echo "[install]" >> ~/.pip/pip.conf && \
    echo "trusted-host= mirrors.aliyun.com" >> ~/.pip/pip.conf; \
    apk add --no-cache git tzdata zlib-dev freetype-dev jpeg-dev libffi-dev mariadb-dev postgresql-dev && \
    apk add --no-cache --virtual .build-deps build-base g++ gcc libxslt-dev python3-dev linux-headers && \
    pip install gunicorn psycopg2 mysqlclient gevent django==3.0.13 && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*; \
    curl -fsSL -o /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 && chmod +x /usr/bin/dumb-init;\
    django-admin startproject mysite



COPY etc/init.d/* /etc/init.d/
COPY default.conf /etc/nginx/conf.d/
COPY docker-entrypoint.sh /usr/local/bin/


RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh


CMD [ "/usr/bin/dumb-init","--","tail", "-f", "/dev/null" ]

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]