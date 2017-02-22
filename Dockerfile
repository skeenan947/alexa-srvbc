FROM ruby

RUN mkdir /app
ADD app.rb /app/
ADD Gemfile /app/
ADD Gemfile.lock /app/
ADD config.ru /app/

RUN cd /app && bundle install

EXPOSE 4567

CMD bash -c "cd /app && bundle exec rackup config.ru -p 4567 -o 0.0.0.0"
