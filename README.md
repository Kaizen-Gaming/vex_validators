# Vex Extra Validators

[Vex](https://github.com/CargoSense/vex) is an extensible data validation library for Elixir.

This library provides new validator [modules that can be used as sources](https://github.com/CargoSense/vex#using-modules-as-sources) in Vex.

## Installation

Add `vex_validators` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vex_validators, github: "StoiximanServices/vex_validators"}
  ]
end
```

Then add in your `config.exs` the following configuration to add as an additional source for Vex:

```elixir
config :vex,
  sources: [VexValidators, Vex.Validators]
```

## Extra validators

Additionally to the built-in Vex validators, `vex_validators` also provides the following validators.

For more information on how to use the validators, please see the [Vex documentation](https://github.com/CargoSense/vex#supported-validations).

### UUID

Ensure a value is a valid UUID string:

```elixir
Vex.valid? post, id: [uuid: true]
```

To check if the value is a valid UUID of a specific format:

```elixir
Vex.valid? post, id: [uuid: :hex]
```

See documentation on `VexValidators.Uuid` for details on available options.
