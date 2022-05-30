defmodule Ecto.PrefixedIDTest do
  use ExUnit.Case
  doctest Ecto.PrefixedID

  alias Ecto.PrefixedID.Base64UUID

  @prefix "cat"
  @binary_uuid <<39, 184, 73, 0, 129, 82, 65, 63, 132, 229, 238, 75, 133, 101, 7, 183>>
  @prefixed_base64_uuid "#{@prefix}_#{@binary_uuid |> Base.url_encode64(padding: false)}"
  @opts Base64UUID.init(prefix: @prefix)

  test "init" do
    assert Base64UUID.init(prefix: "cid") == %{prefix: "cid"}
    assert Base64UUID.init(prefix: "cat") == %{prefix: "cat"}
  end

  test "init fails when prefix is bad" do
    assert_raise ArgumentError, "Prefix `'cid'` is not a 3 character long binary", fn ->
      Base64UUID.init(prefix: 'cid')
    end

    assert_raise ArgumentError, ~S[Prefix `"cider"` is not a 3 character long binary], fn ->
      Base64UUID.init(prefix: "cider")
    end

    assert_raise ArgumentError, ~S[Prefix `nil` is not a 3 character long binary], fn ->
      Base64UUID.init(schema: Foo)
    end
  end

  test "cast" do
    assert Base64UUID.cast(@prefixed_base64_uuid, @opts) == {:ok, "cat_J7hJAIFSQT-E5e5LhWUHtw"}
    assert Base64UUID.cast(@binary_uuid, @opts) == {:ok, "cat_J7hJAIFSQT-E5e5LhWUHtw"}

    assert Base64UUID.cast("xcat_J7hJAIFSQT-E5e5LhWUHtw", @opts) == :error
    assert Base64UUID.cast("cat.J7hJAIFSQT-E5e5LhWUHtw", @opts) == :error
    assert Base64UUID.cast(<<1>> <> @binary_uuid, @opts) == :error
  end

  test "dump" do
    assert Base64UUID.dump(@prefixed_base64_uuid, :dumper, @opts) == {:ok, @binary_uuid}
    assert Base64UUID.dump(nil, :dumper, @opts) == {:ok, nil}
    assert Base64UUID.dump("xcat_J7hJAIFSQT-E5e5LhWUHtw", :dumper, @opts) == :error
    assert Base64UUID.dump(33, :dumper, @opts) == :error
  end

  test "load" do
    assert Base64UUID.load(@binary_uuid, :loader, @opts) == {:ok, "cat_J7hJAIFSQT-E5e5LhWUHtw"}
    assert Base64UUID.load(nil, :loader, @opts) == {:ok, nil}
    assert Base64UUID.load(33, :loader, @opts) == :error
  end

  test "autogenerate" do
    prefixed_base64_uuid = Base64UUID.autogenerate(@opts)
    assert prefixed_base64_uuid =~ ~r(cat_[a-zA-Z0-9_-]+)
    assert String.length(prefixed_base64_uuid) == 3 + 1 + 22
  end
end
