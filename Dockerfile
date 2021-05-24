FROM elixir:alpine

WORKDIR /app

ADD ./app /app

RUN mix local.hex --force
RUN mix deps.get
