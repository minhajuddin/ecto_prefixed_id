defmodule Ecto.PrefixedID.Base64Binary do
  @moduledoc """
  A Base64 encoded binary with a custom 3 letter prefix
  """

  use Ecto.ParameterizedType

  @typedoc """
  A base64-encoded binary string with a 3 letter prefix.
  """
  @type t :: binary

  @typedoc """
  Options for the ParameterizedType
  """
  @type opts :: map

  @typedoc """
  A raw binary representation of a binary.
  """
  @type raw :: binary

  @impl true
  @doc false
  def type(_), do: :binary

  @doc """
  Used by the ParameterizedType to initialize this type with a prefix.
  """
  @impl true
  @spec init(list) :: opts
  def init(opts) when is_list(opts) do
    prefix = opts[:prefix]
    byte_size = opts[:byte_size] || 32

    if not is_number(byte_size) do
      raise ArgumentError, "byte_size `#{inspect(byte_size)}` is not a number"
    end

    if not is_binary(prefix) or byte_size(prefix) != 3 do
      raise ArgumentError, "prefix `#{inspect(prefix)}` is not a 3 character long binary"
    end

    base64_length = (byte_size * 8 / 6) |> :math.ceil() |> round

    opts
    |> Enum.into(%{})
    |> Map.merge(%{byte_size: byte_size, base64_length: base64_length})
  end

  @doc """
  Casts to a binary.
  """
  @impl true
  @spec cast(t | raw | any, opts) :: {:ok, t} | :error
  def cast(id = <<prefix::binary-size(3), ?_, b64_binary::binary>>, %{
        base64_length: base64_length,
        prefix: prefix
      })
      when byte_size(b64_binary) == base64_length do
    {:ok, id}
  end

  def cast(<<_::binary>> = raw_binary, %{byte_size: bin_byte_size} = opts)
      when byte_size(raw_binary) == bin_byte_size,
      do: {:ok, encode(raw_binary, opts)}

  def cast(_, _), do: :error

  @doc """
  Converts a string representing a binary into a raw binary.
  """
  @impl true
  @spec dump(t | any, dumper :: function(), opts) :: {:ok, raw} | :error
  def dump(<<prefix::binary-size(3), ?_, b64_binary::binary>>, _dumper, %{prefix: prefix}) do
    Base.url_decode64(b64_binary, padding: false)
  end

  def dump(nil, _, _), do: {:ok, nil}
  def dump(_, _, _), do: :error

  @doc """
  Converts a binary binary into a string.
  """
  @impl true
  @spec load(raw | any, loader :: function(), opts) :: {:ok, t} | :error
  def load(<<_::binary>> = raw_binary, _loader, %{} = opts), do: {:ok, encode(raw_binary, opts)}
  def load(nil, _, _), do: {:ok, nil}
  def load(_, _, _), do: :error

  @doc """
  Generates a random, version 4 binary.
  """
  @impl true
  def autogenerate(opts) do
    encode(:crypto.strong_rand_bytes(opts[:byte_size]), opts)
  end

  @spec encode(raw, opts) :: t
  defp encode(<<_::binary>> = raw_binary, %{prefix: prefix}) do
    prefix <> "_" <> Base.url_encode64(raw_binary, padding: false)
  end
end
