defmodule Tuesday.Playground.MatchDefault do
  use Ash.Resource,
    domain: Tuesday.Playground

  actions do
    defaults create: :*
  end

  def random_value, do: System.unique_integer()

  attributes do
    uuid_primary_key :id

    attribute :test_same_random1, :integer do
      default &random_value/0
      match_other_defaults? true
    end

    attribute :test_same_random2, :integer do
      default &random_value/0
      match_other_defaults? true
    end

    attribute :test_different_random, :integer do
      default &random_value/0
      match_other_defaults? false
    end
  end
end
