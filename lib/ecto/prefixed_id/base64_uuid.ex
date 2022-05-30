defmodule Ecto.PrefixedID.Base64UUID do
  @moduledoc """
  A Base64 encoded UUID with a custom 3 letter prefix
  """

  use Ecto.ParameterizedType

  @typedoc """
  A base64-encoded UUID string with a 3 letter prefix.
  """
  @type t :: <<_::208>>

  @typedoc """
  Options for the ParameterizedType
  """
  @type opts :: map

  @typedoc """
  A raw binary representation of a UUID.
  """
  @type raw :: <<_::128>>

  @impl true
  @doc false
  def type(_), do: :uuid

  @doc """
  Used by the ParameterizedType to initialize this type with a prefix.
  """
  @impl true
  @spec init(list) :: opts
  def init(opts) when is_list(opts) do
    validate_opts(opts)
    Enum.into(opts, %{})
  end

  defp validate_opts(opts) do
    prefix = opts[:prefix]

    if not is_binary(prefix) or byte_size(prefix) != 3 do
      raise ArgumentError, "Prefix `#{inspect(prefix)}` is not a 3 character long binary"
    end
  end

  @doc """
  Casts to a UUID.
  """
  @impl true
  @spec cast(t | raw | any, opts) :: {:ok, t} | :error
  def cast(id = <<prefix::binary-size(3), ?_, _b64id::binary-size(22)>>, %{prefix: prefix}) do
    {:ok, id}
  end

  def cast(<<_::128>> = raw_uuid, %{} = opts), do: {:ok, encode(raw_uuid, opts)}
  def cast(_, _), do: :error

  @doc """
  Converts a string representing a UUID into a raw binary.
  """
  @impl true
  @spec dump(t | any, dumper :: function(), opts) :: {:ok, raw} | :error
  def dump(<<prefix::binary-size(3), ?_, b64id::binary-size(22)>>, _dumper, %{prefix: prefix}) do
    Base.url_decode64(b64id, padding: false)
  end

  def dump(nil, _, _), do: {:ok, nil}
  def dump(_, _, _), do: :error

  @doc """
  Converts a binary UUID into a string.
  """
  @impl true
  @spec load(raw | any, loader :: function(), opts) :: {:ok, t} | :error
  def load(<<_::128>> = raw_uuid, _loader, %{} = opts), do: {:ok, encode(raw_uuid, opts)}
  def load(nil, _, _), do: {:ok, nil}
  def load(_, _, _), do: :error

  @doc """
  Generates a random, version 4 UUID.
  """
  @impl true
  def autogenerate(opts) do
    encode(Ecto.UUID.bingenerate(), opts)
  end

  @spec encode(raw, opts) :: t
  defp encode(<<_::128>> = raw_uuid, %{prefix: prefix}) do
    prefix <> "_" <> Base.url_encode64(raw_uuid, padding: false)
  end
end
