FROM elixir:alpine as build

LABEL build_date="2021-01-04"

ENV MIX_ENV=prod

RUN mkdir /app
WORKDIR /app

ENV HEX_HTTP_TIMEOUT=500

RUN mix local.hex --force && \
    mix local.rebar --force

RUN echo "0.0.1" > VERSION
RUN echo "## README" > README.md
COPY mix.exs mix.lock ./
RUN mix deps.get --no-archives-check --only prod

RUN mix deps.compile

COPY . .
RUN mix compile

# RUN mix release --overwrite
RUN mix escript.build

# FROM alpine:latest AS app
FROM elixir:alpine AS app
ENV MIX_ENV=prod
ENV LANG=C.UTF-8

ARG GIT_REV
ENV GIT_REV ${GIT_REV}

# RUN apk add bash \
# && rm -rf /tmp/* \
# && rm -rf /var/lib/apt/lists/* \
#     && rm -rf /var/cache/apk/*

RUN mkdir /app
WORKDIR /app
# COPY --from=build /app/_build/prod/rel/elixir_bot ./
# COPY --from=build /app/.iex.exs ./.iex.exs
COPY --from=build /app/elixir_bot ./
ENV HOME=/app

ENTRYPOINT ["./elixir_bot"]
