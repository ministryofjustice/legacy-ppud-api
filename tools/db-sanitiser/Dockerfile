FROM ruby:3.0.2-alpine3.13

ARG BUILD_NUMBER
ARG GIT_REF

RUN apk update \
  && apk upgrade \
  && apk add --no-cache build-base freetds-dev \
  && rm -rf /var/cache/apk/*

RUN addgroup --gid 2000 appuser \
  && adduser --uid 2000 --disabled-password --ingroup appuser --home /app appuser

USER 2000
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set without 'dev' \
  && bundle config set deployment 'true' \
  && bundle config set frozen 'true' \
  && bundle install

COPY . .

CMD ["bundle", "exec", "ruby", "sanitise.rb"]
