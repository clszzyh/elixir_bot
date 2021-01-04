FROM elixir:alpine as build

ENV MIX_ENV=prod

RUN mkdir /app
WORKDIR /app

ENV HEX_HTTP_TIMEOUT=500

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock README.md VERSION ./
RUN mix deps.get

RUN mix deps.compile

COPY . .
RUN mix compile

RUN mix release --overwrite

FROM alpine:latest AS app
ENV MIX_ENV=prod
ENV LANG=C.UTF-8

ARG GIT_REV
ENV GIT_REV ${GIT_REV}

RUN mkdir /app
WORKDIR /app
COPY --from=build /app/_build/prod/rel/elixir_bot ./
COPY --from=build /app/.iex.exs ./.iex.exs
ENV HOME=/app
