# Vex **Extra** Validators

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

## The extra validators

Additionally to the built-in Vex validators, `vex_validators` also provides the following validators.

For more information on how to use the validators, please see the [Vex documentation](https://github.com/CargoSense/vex#supported-validations).

### Number

Ensure a value is a number equal to another:

```elixir
Vex.valid? post, [number: [==: 1]]
```

Ensure a value is a number greater than another:

```elixir
Vex.valid? post, [number: [<: 1]]
```

Ensure a value is a number less than another:

```elixir
Vex.valid? post, [number: [<: 1]]
```

This validation can be skipped for `nil` or blank values by including `allow_nil: true` and/or `allow_blank: true`.

See the documentation on `VexValidators.Number` for details on available options.

### Type

Ensure a value is of a specific Elixir type:

```elixir
Vex.valid? post, [type: :string]
```

This validation can be skipped for `nil` or blank values by including `allow_nil: true` and/or `allow_blank: true`.

See the documentation on `VexValidators.Type` for details on available options.

### UUID

Ensure a value is a valid UUID string:

```elixir
Vex.valid? post, [id: [uuid: true]]
```

To check if the value is a valid UUID of a specific format:

```elixir
Vex.valid? post, [id: [uuid: :hex]]
```

See documentation on `VexValidators.Uuid` for details on available options.
