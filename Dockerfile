FROM ruby:2.5.1-alpine3.7

RUN apk update && apk upgrade && apk add --update --no-cache wget bash git openssh tzdata sqlite-dev nodejs && \
  rm -rf /usr/lib/mysqld* && rm -rf /usr/bin/mysql* && \
  apk add --update --no-cache mysql-client && \
  cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
  rm -rf /var/cache/apk/*

# install reviewdog
# https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

ENV REVIEWDOG_VERSION 0.9.10

RUN wget -O /usr/local/bin/reviewdog -q https://github.com/haya14busa/reviewdog/releases/download/$REVIEWDOG_VERSION/reviewdog_linux_amd64 && \
  chmod +x /usr/local/bin/reviewdog

RUN mkdir /app
WORKDIR /app

ARG BUNDLE_OPTIONS

# install rails
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN apk add --no-cache --virtual .rails-builddeps alpine-sdk && \
  bundle install -j4 ${BUNDLE_OPTIONS} && \
  apk del .rails-builddeps

# install npm packages
ADD package.json /app/package.json
ADD package-lock.json /app/package-lock.json
RUN npm install

ADD . /app

EXPOSE  3000
