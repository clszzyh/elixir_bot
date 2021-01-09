[![ci](https://github.com/clszzyh/elixir_bot/workflows/ci/badge.svg)](https://github.com/clszzyh/elixir_bot/actions)
[![Hex.pm](https://img.shields.io/hexpm/v/elixir_bot)](http://hex.pm/packages/elixir_bot)
[![Hex.pm](https://img.shields.io/hexpm/dt/elixir_bot)](http://hex.pm/packages/elixir_bot)
[![Documentation](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/elixir_bot/readme.html)

<!-- MDOC -->

## Usage

```yml
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

<!-- MDOC -->

## Commands

<!-- MDOC -->

| Command | Description |
| :-- | :- |
| `@ex-bot ping` | `pong` |
| `@ex-bot version` | print current version |

<!-- MDOC -->
