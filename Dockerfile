FROM ruby:alpine

RUN apk add --no-cache --update build-base git

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/Gemfile
COPY Gemfile.lock /usr/src/app/Gemfile.lock
COPY chesto.gemspec /usr/src/app/build_tools.gemspec
COPY . /usr/src/app

RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3
