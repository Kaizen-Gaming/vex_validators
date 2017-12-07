defmodule VexValidators.Number do
  @moduledoc """
  Ensure a value is a number.

  ## Options

  The `options` can be a keyword list with any of the following keys:

  * `:is`: A boolean value whether the value must be or not a number.
  * `:equal_to`: A number where must be equal to the value.
  * `:greater_than`: A number where must be greater than the value.
  * `:greater_or_equal_than`: A number where must be greater than or equal to the value.
  * `:less_than`: A number where must be less than the value.
  * `:less_or_equal_than`: A number where must be less than or equal to the value.

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


  Examples when using the `:equal_to` option:

      iex> VexValidators.Number.validate(3.14, equal_to: 1.41)
      {:error, "must be equal to 1.41"}
      iex> VexValidators.Number.validate(3.14, equal_to: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, equal_to: 6.28)
      {:error, "must be equal to 6.28"}

  Examples when using the `:greater_than` option:

      iex> VexValidators.Number.validate(3.14, greater_than: 1.41)
      :ok
      iex> VexValidators.Number.validate(3.14, greater_than: 3.14)
      {:error, "must be greater than 3.14"}
      iex> VexValidators.Number.validate(3.14, greater_than: 6.28)
      {:error, "must be greater than 6.28"}

  Examples when using the `:greater_or_equal_than` option:

      iex> VexValidators.Number.validate(3.14, greater_or_equal_than: 1.41)
      :ok
      iex> VexValidators.Number.validate(3.14, greater_or_equal_than: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, greater_or_equal_than: 6.28)
      {:error, "must be greater or equal than 6.28"}

  Examples when using the `:less_than` option:

      iex> VexValidators.Number.validate(3.14, less_than: 1.41)
      {:error, "must be less than 1.41"}
      iex> VexValidators.Number.validate(3.14, less_than: 3.14)
      {:error, "must be less than 3.14"}
      iex> VexValidators.Number.validate(3.14, less_than: 6.28)
      :ok

  Examples when using the `:less_or_equal_than` option:

      iex> VexValidators.Number.validate(3.14, less_or_equal_than: 1.41)
      {:error, "must be less or equal than 1.41"}
      iex> VexValidators.Number.validate(3.14, less_or_equal_than: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, less_or_equal_than: 6.28)
      :ok

  Examples when using the combinations of the above options:

      iex> VexValidators.Number.validate("not_a_number", is: true, greater_than: 0, less_or_equal_than: 3.14)
      {:error, "must be a number"}
      iex> VexValidators.Number.validate(0, is: true, greater_than: 0, less_or_equal_than: 3.14)
      {:error, "must be greater than 0"}
      iex> VexValidators.Number.validate(1.41, is: true, greater_than: 0, less_or_equal_than: 3.14)
      :ok
      iex> VexValidators.Number.validate(3.14, is: true, greater_than: 0, less_or_equal_than: 3.14)
      :ok
      iex> VexValidators.Number.validate(6.28, is: true, greater_than: 0, less_or_equal_than: 3.14)
      {:error, "must be less or equal than 3.14"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> VexValidators.Number.__validator__(:message_fields)
      [value: "Bad value", is: "Is number", equal_to: "Equal to",
       greater_than: "Greater than", greater_or_equal_than: "Greater or equal than",
       less_than: "Less than", less_or_equal_than: "Less or equal than"]

  For examples please see the [Vex documentation](https://github.com/CargoSense/vex#custom-eex-error-renderer-messages).
  """

  use Vex.Validator

  @doc false
  @message_fields [value: "Bad value", is: "Is number", equal_to: "Equal to",
                   greater_than: "Greater than", greater_or_equal_than: "Greater or equal than",
                   less_than: "Less than", less_or_equal_than: "Less or equal than"]
  def validate(value, options) when is_boolean(options), do: validate(value, is: options)
  def validate(value, options) when is_list(options) do
    unless_skipping(value, options) do
      with \
        :ok <- do_validate_is(value, options[:is]),
        :ok <- do_validate_equal_to(value, options[:equal_to]),
        :ok <- do_validate_greater_than(value, options[:greater_than]),
        :ok <- do_validate_greater_or_equal_than(value, options[:greater_or_equal_than]),
        :ok <- do_validate_less_than(value, options[:less_than]),
        :ok <- do_validate_less_or_equal_than(value, options[:less_or_equal_than])
      do
        :ok
      else
        {:error, reason} ->
          fields = [
            value: value,
            is: options[:is],
            equal_to: options[:equal_to],
            greater_than: options[:greater_than],
            greater_or_equal_than: options[:greater_or_equal_than],
            less_than: options[:less_than],
            less_or_equal_than: options[:less_or_equal_than]
          ]
          {:error, message(options, reason, fields)}
      end
    end
  end

  defp do_validate_is(_, nil), do: :ok
  defp do_validate_is(value, is) when is_number(value) === is, do: :ok
  defp do_validate_is(_, true), do: {:error, "must be a number"}
  defp do_validate_is(_, false), do: {:error, "must not be a number"}

  defp do_validate_equal_to(_, nil), do: :ok
  defp do_validate_equal_to(value, other) when value == other, do: :ok
  defp do_validate_equal_to(_, other), do: {:error, "must be equal to #{other}"}

  defp do_validate_greater_than(_, nil), do: :ok
  defp do_validate_greater_than(value, other) when value > other, do: :ok
  defp do_validate_greater_than(_, other), do: {:error, "must be greater than #{other}"}

  defp do_validate_greater_or_equal_than(_, nil), do: :ok
  defp do_validate_greater_or_equal_than(value, other) when value >= other, do: :ok
  defp do_validate_greater_or_equal_than(_, other), do: {:error, "must be greater or equal than #{other}"}

  defp do_validate_less_than(_, nil), do: :ok
  defp do_validate_less_than(value, other) when value < other, do: :ok
  defp do_validate_less_than(_, other), do: {:error, "must be less than #{other}"}

  defp do_validate_less_or_equal_than(_, nil), do: :ok
  defp do_validate_less_or_equal_than(value, other) when value <= other, do: :ok
  defp do_validate_less_or_equal_than(_, other), do: {:error, "must be less or equal than #{other}"}

end
