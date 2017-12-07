defmodule VexValidators.Type do

  @types [:integer, :float, :boolean, :atom, :string, :binary, :list, :map, :tuple]
  @tests %{
    1 => [:integer],
    1.0 => [:float],
    true => [:boolean, :atom],
    :atom => [:atom],
    "string" => [:binary, :string],
    <<0>> => [:binary, :string],
    [] => [:list],
    %{} => [:map],
    {} => [:tuple],
  }

  @moduledoc """
  Ensure a value is a spefic type.

  ## Options

  The `options` can be a keyword list with any of the following keys:

  * `:is`: The type of the value. The values of this options can be:

  * `:integer`: The value must be an integer.
  * `:float`: The value must be a float.
  * `:boolean`: The value must be a boolean.
  * `:atom`: The value must be an atom.
  * `:string` or `:binary`: The value must be a binary/string.
  * `:list`: The value must be a list.
  * `:map`: The value must be a map.
  * `:tuple`: The value must be a tuple.

  The `options` can also be an atom instead of the keyword list, which will be the value of the `:is` option.

  ## Examples
#{Enum.map(@types, fn t ->
  ["\n\n  Examples when using the `:is` option with the value `#{inspect(t)}`:\n\n"] ++
  Enum.map(@tests, fn {v, ts} ->
    "    iex> VexValidators.Type.validate(#{inspect(v)}, is: #{inspect(t)})\n    " <>
    if t in ts, do: ":ok", else: "{:error, \"must be of type #{t}\"}"
  end)
end)
|> List.flatten() |> Enum.join("\n")}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> VexValidators.Type.__validator__(:message_fields)
      [value: "Bad value", is: "Is type"]

  For examples please see the [Vex documentation](https://github.com/CargoSense/vex#custom-eex-error-renderer-messages).
  """

  use Vex.Validator

  @doc false
  @message_fields [value: "Bad value", is: "Is type"]
  def validate(value, options) when options in @types, do: validate(value, is: options)
  def validate(value, options) when is_list(options) do
    unless_skipping(value, options) do
      is = options[:is]
      case do_validate(value, is) do
        :ok -> :ok
        {:error, reason} -> {:error, message(options, reason, value: value, is: is)}
      end
    end
  end

  defp do_validate(value, :integer) when is_integer(value), do: :ok
  defp do_validate(value, :float) when is_float(value), do: :ok
  defp do_validate(value, :boolean) when is_boolean(value), do: :ok
  defp do_validate(value, :atom) when is_atom(value), do: :ok
  defp do_validate(value, :string) when is_binary(value), do: :ok
  defp do_validate(value, :binary) when is_binary(value), do: :ok
  defp do_validate(value, :list) when is_list(value), do: :ok
  defp do_validate(value, :map) when is_map(value), do: :ok
  defp do_validate(value, :tuple) when is_tuple(value), do: :ok
  defp do_validate(_, type), do: {:error, "must be of type #{type}"}

end
