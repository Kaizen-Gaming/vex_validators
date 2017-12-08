defmodule VexValidatorsTest do

  use ExUnit.Case

  doctest VexValidators.Number
  doctest VexValidators.Type
  doctest VexValidators.Uuid

  test "can validate UUID with Vex.valid?" do
    data = %{foo: "5FCF6936-0F5A-41C6-9716-9B3274AAB6D8", bar: "baz"}

    assert true == Vex.valid?(data, foo: [uuid: true])
    assert true == Vex.valid?(data, foo: [uuid: :default])
    assert false == Vex.valid?(data, foo: [uuid: :hex])
    assert false == Vex.valid?(data, foo: [uuid: :urn])
    assert true == Vex.valid?(data, foo: [uuid: [format: :any, allow_nil: true]])
  end

end
