FROM ruby:2.5.3

ARG UID=1000
ARG GID=1000
ARG DOCKER_GROUP_ID

ENV APP_HOME=/home/app \
    COMPOSE_VERSION=1.23.2

RUN groupadd -r --gid ${GID} app \
 && useradd --system --create-home --home ${APP_HOME} --shell /sbin/nologin --no-log-init \
      --gid ${GID} --uid ${UID} app
RUN groupadd -g $DOCKER_GROUP_ID docker && gpasswd -a app docker

WORKDIR $APP_HOME 

COPY --chown=app:app Gemfile Gemfile.lock $APP_HOME/

RUN bundle install --jobs=$(nproc) --deployment

RUN curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
      && chmod +x /usr/local/bin/docker-compose

COPY --chown=app:app lib $APP_HOME/lib/

USER app

EXPOSE 4567

CMD [ "bundle", "exec", "ruby", "lib/microkube/server.rb" ]
