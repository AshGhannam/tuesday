defmodule Tuesday.Auth.User do
  use Ash.Resource,
    domain: Tuesday.Auth,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "users"
    repo Tuesday.Repo
  end

  resource do
    description """
    `User` represents an individual human uniquely identified by their email address.
     It only stores the barest minimum details needed to authenticate a human.

    A single `User` can be a member of multiple `Organization`. Information about the
    user that is specific to an organization is managed in `OrganizationMember` resource.
    """
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    create :register_user do
      description "Creates a new user"

      accept [:email]
    end

    update :update_user do
      description "Update the user"

      accept [:email]
    end
  end

  policies do
    policy action(:register_user) do
      authorize_if actor_absent()
    end

    policy action(:update_user) do
      authorize_if expr(id == ^actor(:user_id))
    end
  end

  @email_regex ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

  validations do
    validate present(:email), message: "Email ID is required"
    validate match(:email, @email_regex), message: "Email ID is invalid"
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      sensitive? true
      public? true
    end

    timestamps()
  end

  identities do
    identity :unique_email, [:email] do
      description "Ensures email is globally unique."
      message "A user with the given email already exists."
    end
  end
end
