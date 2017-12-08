defmodule VexValidators.Uuid do
  @moduledoc """
  Ensure a value is a valid UUID string.

  ## Options

  The `options` can be a keyword list with the following keys:

  * `:format`: An atom or boolean that defines the validation & format of the UUID:

    * `:default`: The value must a string with format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx`
      where `x` is a hex number.
    * `:hex`: The value must be a string with the format `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
      where `x` is a hex number.
    * `:urn`: The value must be a string with the format `urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx`
      where `x` is a hex number.
    * `:any` or `true`: The value must be a string of any of the supported formats (`:default`, `:hex` or `:urn`).
    * `:not_any` or `false`: The value must **not** be a valid UUID string.

  The options can also be an atom or boolean instead of the keyword list, which is the value of the `:format` option.

  ## Examples

  Examples when using the `:any` or `true` options:

      iex> VexValidators.Uuid.validate(:not_a_guid, :any)
      {:error, "must be a valid UUID"}
      iex> VexValidators.Uuid.validate("not_a_uuid", :any)
      {:error, "must be a valid UUID"}
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", :any)
      :ok
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a30", :any)
      {:error, "must be a valid UUID"}

      iex> VexValidators.Uuid.validate(:not_a_guid, true)
      {:error, "must be a valid UUID"}
      iex> VexValidators.Uuid.validate("not_a_uuid", true)
      {:error, "must be a valid UUID"}
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", true)
      :ok
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a30", true)
      {:error, "must be a valid UUID"}

  Examples when using the `:not_any` or `false` options:

      iex> VexValidators.Uuid.validate(:not_a_guid, :not_any)
      :ok
      iex> VexValidators.Uuid.validate("not_a_uuid", :not_any)
      :ok
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", :not_any)
      {:error, "must not be a UUID"}
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a30", :not_any)
      :ok

      iex> VexValidators.Uuid.validate(:not_a_guid, false)
      :ok
      iex> VexValidators.Uuid.validate("not_a_uuid", false)
      :ok
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", false)
      {:error, "must not be a UUID"}
      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a30", false)
      :ok

  Examples when using the `:default` option:

      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", :default)
      :ok
      iex> VexValidators.Uuid.validate("02aa7f483ccd11e4b63e14109ff1a304", :default)
      {:error, "must be a valid UUID in :default format"}
      iex> VexValidators.Uuid.validate("urn:uuid:02aa7f48-3ccd-11e4-b63e-14109ff1a304", :default)
      {:error, "must be a valid UUID in :default format"}

  Examples when using the `:hex` option:

      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", :hex)
      {:error, "must be a valid UUID in :hex format"}
      iex> VexValidators.Uuid.validate("02aa7f483ccd11e4b63e14109ff1a304", :hex)
      :ok
      iex> VexValidators.Uuid.validate("urn:uuid:02aa7f48-3ccd-11e4-b63e-14109ff1a304", :hex)
      {:error, "must be a valid UUID in :hex format"}

  Examples when using the `:urn` option:

      iex> VexValidators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", :urn)
      {:error, "must be a valid UUID in :urn format"}
      iex> VexValidators.Uuid.validate("02aa7f483ccd11e4b63e14109ff1a304", :urn)
      {:error, "must be a valid UUID in :urn format"}
      iex> VexValidators.Uuid.validate("urn:uuid:02aa7f48-3ccd-11e4-b63e-14109ff1a304", :urn)
      :ok

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> VexValidators.Uuid.__validator__(:message_fields)
      [value: "Bad value", format: "UUID format"]

  For examples please see the [Vex documentation](https://github.com/CargoSense/vex#custom-eex-error-renderer-messages).
  """

  use Vex.Validator

  @any_formats [:default, :hex, :urn]
  @all_formats @any_formats ++ [:any, :not_any]
  @urn_prefix "urn:uuid:"

  @doc false
  @message_fields [value: "Bad value", format: "UUID format"]
  def validate(value, true), do: validate(value, format: :any)
  def validate(value, false), do: validate(value, format: :not_any)
  def validate(value, options) when options in @all_formats, do: validate(value, format: options)
  def validate(value, options) when is_list(options) do
    unless_skipping(value, options) do
      format = options[:format]
      case do_validate(value, format) do
        :ok -> :ok
        {:error, reason} -> {:error, message(options, reason, value: value, format: format)}
      end
    end
  end

  defp do_validate(<<_u0::64, ?-, _u1::32, ?-, _u2::32, ?-, _u3::32, ?-, _u4::96>>, :default) do
    :ok
  end
  defp do_validate(<<_u::256>>, :hex) do
    :ok
  end
  defp do_validate(<<@urn_prefix, _u0::64, ?-, _u1::32, ?-, _u2::32, ?-, _u3::32, ?-, _u4::96>>, :urn) do
    :ok
  end
  defp do_validate(_, format) when format in @any_formats do
    {:error, "must be a valid UUID in #{inspect(format)} format"}
  end
  defp do_validate(value, :any) do
    Enum.reduce_while(@any_formats, {:error, "must be a valid UUID"}, fn
      format, _ ->
        case do_validate(value, format) do
          :ok -> {:halt, :ok}
          _ -> {:cont, {:error, "must be a valid UUID"}}
        end
    end)
  end
  defp do_validate(value, :not_any) do
    Enum.reduce_while(@any_formats, :ok, fn
      format, _ ->
        case do_validate(value, format) do
          :ok -> {:halt, {:error, "must not be a UUID"}}
          _ -> {:cont, :ok}
        end
    end)
  end
  defp do_validate(_, _) do
    {:error, "must provide a valid UUID format in options"}
  end

end
