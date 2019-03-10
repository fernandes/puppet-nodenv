FROM ruby:2.1-onbuild
MAINTAINER Celso Fernandes <celso.fernandes@gmail.com>

RUN bundle exec rake spec
