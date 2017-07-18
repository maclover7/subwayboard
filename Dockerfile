FROM ruby:2.3.3

RUN gem install bundler

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN bundle install --deployment --without development

ADD Procfile /app/Procfile
ADD config.ru /app/config.ru
ADD app.rb /app/app.rb
ADD views/index.erb /app/views/index.erb
ADD views/partials/line.erb /app/views/partials/line.erb
ADD views/partials/incident.erb /app/views/partials/incident.erb

EXPOSE 3000

CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile"]
