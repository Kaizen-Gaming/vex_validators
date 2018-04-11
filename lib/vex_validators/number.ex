defmodule VexValidators.Number do
  @moduledoc """
  Ensure a value is a number.

  ## Options

  The `options` can be a keyword list with any of the following keys:

  * `:is`: A boolean value whether the value must be or not a number.
  * `:==`: A number where must be equal to the value.
  * `:>`: A number where must be greater than the value.
  * `:>=`: A number where must be greater than or equal to the value.
  * `:<`: A number where must be less than the value.
  * `:<=`: A number where must be less than or equal to the value.

  When multiple keys are set in the option than the validator will do a logic "and" between them.
  The `options` can also be a boolean instead of the keyword list, which will be the value of the `:is` option.

  ## Examples

  Examples when using the `:is` option:

      iex> VexValidators.Number.validate("not_a_number", is: true)
      {:error, "must be a number"}
      iex> VexValidators.Number.validate(3.14, is: true)
      :ok

      iex> VexValidators.Number.validate("not_a_number", is: false)
      :ok
      iex> VexValidators.Number.validate(3.14, is: false)
      {:error, "must not be a number"}

  Examples when using the boolean value in options for the `:is` option:

      iex> VexValidators.Number.validate("not_a_number", true)
      {:error, "must be a number"}
      iex> VexValidators.Number.validate(3.14, true)
      :ok

      iex> VexValidators.Number.validate("not_a_number", false)
      :ok
      iex> VexValidators.Number.validate(3.14, false)
      {:error, "must not be a number"}


  Examples when using the `:==` option:

      iex> VexValidators.Number.validate(3.14, ==: 1.41)
      {:error, "must be a number equal to 1.41"}
      iex> VexValidators.Number.validate(3.14, ==: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, ==: 6.28)
      {:error, "must be a number equal to 6.28"}

  Examples when using the `:>` option:

      iex> VexValidators.Number.validate(3.14, >: 1.41)
      :ok
      iex> VexValidators.Number.validate(3.14, >: 3.14)
      {:error, "must be a number greater than 3.14"}
      iex> VexValidators.Number.validate(3.14, >: 6.28)
      {:error, "must be a number greater than 6.28"}

  Examples when using the `:>=` option:

      iex> VexValidators.Number.validate(3.14, >=: 1.41)
      :ok
      iex> VexValidators.Number.validate(3.14, >=: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, >=: 6.28)
      {:error, "must be a number greater or equal than 6.28"}

  Examples when using the `:<` option:

      iex> VexValidators.Number.validate(3.14, <: 1.41)
      {:error, "must be a number less than 1.41"}
      iex> VexValidators.Number.validate(3.14, <: 3.14)
      {:error, "must be a number less than 3.14"}
      iex> VexValidators.Number.validate(3.14, <: 6.28)
      :ok

  Examples when using the `:<=` option:

      iex> VexValidators.Number.validate(3.14, <=: 1.41)
      {:error, "must be a number less or equal than 1.41"}
      iex> VexValidators.Number.validate(3.14, <=: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, <=: 6.28)
      :ok

  Examples when using the combinations of the above options:

      iex> VexValidators.Number.validate("not_a_number", is: true, >: 0, <=: 3.14)
      {:error, "must be a number"}
      iex> VexValidators.Number.validate(0, is: true, >: 0, <=: 3.14)
      {:error, "must be a number greater than 0"}
      iex> VexValidators.Number.validate(1.41, is: true, >: 0, <=: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, is: true, >: 0, <=: 3.14)
      :ok
      iex> VexValidators.Number.validate(6.28, is: true, >: 0, <=: 3.14)
      {:error, "must be a number less or equal than 3.14"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> VexValidators.Number.__validator__(:message_fields)
      [                             
        value: "Bad value",         
        is: "Is number",            
        ==: "Equal to",             
        >: "Greater than",          
        >=: "Greater or equal than",
        <: "Less than",             
        <=: "Less or equal than"    
      ]

  For examples please see the [Vex documentation](https://github.com/CargoSense/vex#custom-eex-error-renderer-messages).
  """

  use Vex.Validator

  @option_keys [:is, :==, :>, :>=, :<, :<=]

  @message_fields [
    value: "Bad value",
    is: "Is number",
    ==: "Equal to",
    >: "Greater than",
    >=: "Greater or equal than",
    <: "Less than",
    <=: "Less or equal than"
  ]

  @doc false
  def validate(value, options) when is_boolean(options), do: validate(value, is: options)

  def validate(value, options) when is_list(options) do
    unless_skipping value, options do
      Enum.reduce_while(options, :ok, fn
        {k, o}, _ when k in @option_keys ->
          case do_validate(value, k, o) do
            :ok ->
              {:cont, :ok}

            {:error, reason} ->
              fields =
                options
                |> Keyword.take(@option_keys)
                |> Keyword.put(:value, value)

              error = {:error, message(options, reason, fields)}

              {:halt, error}
          end

        _, _ ->
          {:cont, :ok}
      end)
    end
  end

  defp do_validate(_, :is, nil), do: :ok
  defp do_validate(v, :is, o) when is_number(v) === o, do: :ok
  defp do_validate(_, :is, true), do: {:error, "must be a number"}
  defp do_validate(_, :is, false), do: {:error, "must not be a number"}

  defp do_validate(_, :==, nil), do: :ok
  defp do_validate(v, :==, o) when is_number(v) and v == o, do: :ok
  defp do_validate(_, :==, o), do: {:error, "must be a number equal to #{o}"}

  defp do_validate(_, :>, nil), do: :ok
  defp do_validate(v, :>, o) when is_number(v) and v > o, do: :ok
  defp do_validate(_, :>, o), do: {:error, "must be a number greater than #{o}"}

  defp do_validate(_, :>=, nil), do: :ok
  defp do_validate(v, :>=, o) when is_number(v) and v >= o, do: :ok
  defp do_validate(_, :>=, o), do: {:error, "must be a number greater or equal than #{o}"}

  defp do_validate(_, :<, nil), do: :ok
  defp do_validate(v, :<, o) when is_number(v) and v < o, do: :ok
  defp do_validate(_, :<, o), do: {:error, "must be a number less than #{o}"}

  defp do_validate(_, :<=, nil), do: :ok
  defp do_validate(v, :<=, o) when is_number(v) and v <= o, do: :ok
  defp do_validate(_, :<=, o), do: {:error, "must be a number less or equal than #{o}"}
end
