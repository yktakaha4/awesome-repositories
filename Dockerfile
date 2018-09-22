FROM ruby:2.5-alpine

RUN apk add --update --no-cache alpine-sdk mariadb-dev nodejs tzdata

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]