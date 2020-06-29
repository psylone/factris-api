FROM ruby:2.7.1-alpine3.12

RUN apk add --no-cache \
  build-base \
  tzdata \
  postgresql-dev

WORKDIR /usr/src/app

COPY . .

RUN mkdir tmp/pids

RUN bundle install --jobs 4 --retry 3

EXPOSE 3000

CMD ["bin/puma"]
