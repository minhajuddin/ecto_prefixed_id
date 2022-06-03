defmodule Ecto.PrefixedID.Base64UUIDTest do
  use ExUnit.Case
  doctest Ecto.PrefixedID

  alias Ecto.PrefixedID.Base64UUID

  defmodule Util do
    def build_prefixed_base64_uuid(nil, binary_uuid) do
      binary_uuid |> Base.url_encode64(padding: false)
    end

    def build_prefixed_base64_uuid(prefix, binary_uuid) do
      "#{prefix}_#{binary_uuid |> Base.url_encode64(padding: false)}"
    end
  end

  for prefix <- ["cat", nil] do
    @prefix prefix
    @binary_uuid <<39, 184, 73, 0, 129, 82, 65, 63, 132, 229, 238, 75, 133, 101, 7, 183>>
    @prefixed_base64_uuid Ecto.PrefixedID.Base64UUIDTest.Util.build_prefixed_base64_uuid(
                            @prefix,
                            @binary_uuid
                          )
    @opts Base64UUID.init(prefix: @prefix)

    describe "prefix=#{inspect(@prefix)}" do
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
      end

      test "cast" do
        assert Base64UUID.cast(@prefixed_base64_uuid, @opts) ==
                 {:ok, @prefixed_base64_uuid}

        assert Base64UUID.cast(@binary_uuid, @opts) == {:ok, @prefixed_base64_uuid}

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
        assert Base64UUID.load(@binary_uuid, :loader, @opts) ==
                 {:ok, @prefixed_base64_uuid}

        assert Base64UUID.load(nil, :loader, @opts) == {:ok, nil}
        assert Base64UUID.load(33, :loader, @opts) == :error
      end

      test "autogenerate" do
        prefixed_base64_uuid = Base64UUID.autogenerate(@opts)

        assert_prefix = fn
          nil ->
            assert prefixed_base64_uuid =~ ~r([a-zA-Z0-9_-]+)
            assert String.length(prefixed_base64_uuid) == 22

          prefix ->
            assert prefixed_base64_uuid =~ ~r(#{prefix}_[a-zA-Z0-9_-]+)
            assert String.length(prefixed_base64_uuid) == 3 + 1 + 22
        end

        assert_prefix.(@prefix)
      end
    end
  end
end
