FROM ruby:alpine

RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev git
RUN adduser -D -u 1000 app
RUN mkdir /app && chown app /app
USER app
WORKDIR /app
COPY . /app
RUN bundle install --path vendor

EXPOSE 5000
CMD ["bundle", "exec", "rackup", "-p", "5000"]
