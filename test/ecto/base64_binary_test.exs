defmodule Ecto.PrefixedID.Base64BinaryTest do
  use ExUnit.Case
  doctest Ecto.PrefixedID

  alias Ecto.PrefixedID.Base64Binary

  @prefix "cat"
  @binary_uuid <<37, 49, 145, 228, 118, 254, 213, 251, 100, 90, 109, 69, 225, 182, 7, 193, 150,
                 185, 187, 36, 242, 70, 90, 117>>
  @prefixed_base64_uuid "cat_JTGR5Hb-1ftkWm1F4bYHwZa5uyTyRlp1"
  @opts Base64Binary.init(prefix: @prefix, byte_size: 24)

  test "init" do
    assert Base64Binary.init(prefix: "cid", byte_size: 32) == %{
             prefix: "cid",
             byte_size: 32,
             base64_length: 43
           }

    assert Base64Binary.init(prefix: "cat", byte_size: 24) == %{
             prefix: "cat",
             byte_size: 24,
             base64_length: 32
           }

    assert Base64Binary.init(prefix: "cat", byte_size: 16) == %{
             prefix: "cat",
             byte_size: 16,
             base64_length: 22
           }
  end

  test "init fails when prefix is bad" do
    assert_raise ArgumentError, "prefix `'cid'` is not a 3 character long binary", fn ->
      Base64Binary.init(prefix: 'cid', byte_size: 32)
    end

    assert_raise ArgumentError, ~S[prefix `"cider"` is not a 3 character long binary], fn ->
      Base64Binary.init(prefix: "cider", byte_size: 32)
    end

    assert_raise ArgumentError, ~S[prefix `nil` is not a 3 character long binary], fn ->
      Base64Binary.init(schema: Foo, byte_size: 32)
    end

    assert_raise ArgumentError, ~S[byte_size `:x` is not a number], fn ->
      Base64Binary.init(prefix: "foo", byte_size: :x)
    end
  end

  test "cast" do
    assert Base64Binary.cast(@prefixed_base64_uuid, @opts) == {:ok, @prefixed_base64_uuid}
    assert Base64Binary.cast(@binary_uuid, @opts) == {:ok, @prefixed_base64_uuid}

    assert Base64Binary.cast("xcat_J7hJAIFSQT-E5e5LhWUHtw", @opts) == :error
    assert Base64Binary.cast("cat.J7hJAIFSQT-E5e5LhWUHtw", @opts) == :error
    assert Base64Binary.cast(<<1>> <> @binary_uuid, @opts) == :error
  end

  test "dump" do
    assert Base64Binary.dump(@prefixed_base64_uuid, :dumper, @opts) == {:ok, @binary_uuid}
    assert Base64Binary.dump(nil, :dumper, @opts) == {:ok, nil}
    assert Base64Binary.dump("xcat_J7hJAIFSQT-E5e5LhWUHtw", :dumper, @opts) == :error
    assert Base64Binary.dump(33, :dumper, @opts) == :error
  end

  test "load" do
    assert Base64Binary.load(@binary_uuid, :loader, @opts) == {:ok, @prefixed_base64_uuid}
    assert Base64Binary.load(nil, :loader, @opts) == {:ok, nil}
    assert Base64Binary.load(33, :loader, @opts) == :error
  end

  test "autogenerate" do
    prefixed_base64_uuid = Base64Binary.autogenerate(@opts)
    assert prefixed_base64_uuid =~ ~r(cat_[a-zA-Z0-9_-]+)
    assert String.length(prefixed_base64_uuid) == 3 + 1 + 32
  end
end
