FROM ruby

RUN mkdir /app
ADD app.rb /app/
ADD Gemfile /app/
ADD Gemfile.lock /app/
ADD config.ru /app/

RUN cd /app && bundle install

EXPOSE 4567

WORKDIR /app
CMD bundle exec ruby app.rb -p 4567 -a 0.0.0.0
