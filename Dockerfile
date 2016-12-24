FROM ruby:2.1.5

RUN apt-get update && apt-get install -y nodejs

RUN mkdir -p /usr/src
COPY . /usr/src/app/
WORKDIR /usr/src/app

#COPY Gemfile /usr/src/app
#COPY Gemfile.lock /usr/src/app
RUN bundle install

#VOLUME /usr/src/app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
