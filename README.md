[![ci](https://github.com/clszzyh/elixir_bot/workflows/ci/badge.svg)](https://github.com/clszzyh/elixir_bot/actions)
[![Hex.pm](https://img.shields.io/hexpm/v/elixir_bot)](http://hex.pm/packages/elixir_bot)
[![Hex.pm](https://img.shields.io/hexpm/dt/elixir_bot)](http://hex.pm/packages/elixir_bot)
[![Documentation](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/elixir_bot/readme.html)

[demo](https://github.com/clszzyh/elixir_bot/issues/61)

<!-- MDOC -->

## Usage

```yml
## .github/workflows/event.yml
name: event

on:
  workflow_dispatch:
  issue_comment:
    types: [created, edited]
  issues:
    types: [opened, edited]

jobs:
  exbot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: clszzyh/elixir_bot@main
```

## Eval Elixir Code

Create an issue or comment with

```
​```elixir
## @ex-bot
r factorial = fn
  1 -> 1
  n -> n * factorial.(n - 1)
end

factorial.(22222)
​```
```

See also [sand package](https://github.com/bopjesvla/sand) for elixir sandbox.

## Commands

Create an issue or comment with

```sh
@ex-bot {{command}} {{args}}
```

<!-- MDOC -->

| Command | Args | Description |
| :-- | :- | --- |
| `@ex-bot ping` |  | `pong` |
| `@ex-bot version` |  | print current version |

<!-- MDOC -->

