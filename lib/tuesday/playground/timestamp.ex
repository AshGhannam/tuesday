defmodule Tuesday.Playground.Timestamp do
  use Ash.Resource,
    domain: Tuesday.Playground

  actions do
    defaults create: :*
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, public?: true

    attribute :inserted_at, Ash.Type.UtcDatetimeUsec do
      writable? false
      default &DateTime.utc_now/0
      match_other_defaults? true
      allow_nil? false
    end

    attribute :updated_at, Ash.Type.UtcDatetimeUsec do
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      match_other_defaults? false
      allow_nil? false
    end
  end
end
