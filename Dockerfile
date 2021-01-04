FROM elixir:alpine as build

# ENV HEX_MIRROR=https://hexpm.upyun.com
ENV MIX_ENV=prod

RUN mkdir /app
WORKDIR /app

ENV HEX_HTTP_TIMEOUT=500
ENV HEX_MIRROR=http://hexpm.upyun.com
ENV HEX_HTTP_CONCURRENCY=1

RUN mix local.hex --force && \
    mix local.rebar --force

ENV HEX_HTTP_TIMEOUT=50000
# ENV HEX_MIRROR=https://cdn.jsdelivr.net/hex

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
