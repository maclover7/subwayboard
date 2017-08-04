FROM ruby:2.3.3

RUN gem install bundler

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN bundle install --deployment --without development

ADD . /app

EXPOSE 3000

CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile"]
