FROM nginx:1.21.5

ARG proxy
ARG no_proxy

ENV http_proxy=$proxy
ENV https_proxy=$proxy
ENV NO_PROXY=$no_proxy

RUN printenv

RUN apt update && \
    apt install locales curl -y

RUN echo 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=ja_JP.UTF-8

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt update && \
    apt install -y nodejs && \
    apt clean

COPY ./docker/front/config/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/front/config/default.conf /etc/nginx/conf.d/default.conf
COPY docker/front/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt/app
COPY front /opt/app
RUN cd /opt/app && npm update -g npm && npm install && npm run generate