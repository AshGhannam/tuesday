defmodule Tuesday.Playground.Post do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    domain: Tuesday.Playground,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "posts"
    repo Tuesday.Repo
  end

  resource do
    description """
    Resources under `Playground` domain are planned for practicing various concept of Ash
    without getting too much distracted by the complex business needs of Tuesday project.

    Feel free to modify this resource as needed to play with Ash. There are no seed data or test written
    for this resource.
    """
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? false
      select_by_default? false
    end
  end
end
