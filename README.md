# Ecto.PrefixedID

Encode UUIDs and Binaries as prefixed base64 strings similar to [Stripe's
prefixed IDs](https://gist.github.com/fnky/76f533366f75cf75802c8052b577e2a5).


### Use it for a primary key

```elixir
defmodule User do
  use Ecto.Schema
  @primary_key {:id, Ecto.PrefixID.Base64UUID, autogenerate: true, prefix: "usr"}
  schema "users" do
  # ...
  end
end

Repo.insert!(%User{...}) => %User{id: "usr_l6atnMk5TnqnK8cL41nS2w"}
```

### Use it for a binary blob of data

```elixir
defmodule Client do
  use Ecto.Schema
  schema "clients" do
    field :secret, Ecto.PrefixID.Binary, autogenerate: true, prefix: "cls", length: 32
  end
end

Repo.insert!(%Client{...}) => %Client{secret: "cls_zbRihf31ZicYFS3k-1S17Nm4PVtXUKmCTNQGPGQ3fSc"}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_prefixed_id` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_prefixed_id, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ecto_prefixed_id>.

