# Ash Archival

A small but useful resource extension for [Ash Framework](https://github.com/ash-project/ash), which configures resources to be archived instead of destroyed.

## Installation

The package can be installed by adding `ash_archival` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ash_archival, "~> 0.1"}
  ]
end
```

## Using the archive extension

On your ash resource add `AshArchival.Resource` to your extensions. For more details see the docs at https://ash-hq.org.

```elixir
  use Ash.Resource,
    extensions: [AshArchival.Resource]
```
