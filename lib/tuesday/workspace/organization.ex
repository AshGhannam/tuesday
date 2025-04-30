defmodule Tuesday.Workspace.Organization do
  use Ash.Resource,
    domain: Tuesday.Workspace,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "organizations"
    repo Tuesday.Repo
  end

  resource do
    description """
    Organization captures the business entity that pays for managing its projects and tasks.
    """
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    create :create_org_with_owner do
      description """
        Creates a new organization along with new organization member with role set to owner.
      """

      argument :member, :map, allow_nil?: false

      accept [:name, :plan_type]

      change fn
        %{valid?: true} = changeset, _ctx ->
          slug =
            Ash.Changeset.get_attribute(changeset, :name)
            |> String.downcase()
            |> String.replace(~r/\s+/, "-")

          Ash.Changeset.force_change_attribute(changeset, :slug, slug)

        changeset, _ctx ->
          changeset
      end

      change manage_relationship(:member, :organization_members,
               on_no_match: {:create, :invite_org_member},
               on_match: :ignore
             )
    end

    update :update_org do
      description "Updates organization details."

      accept [:name, :can_standard_member_create_project]
    end

    update :change_org_plan do
      description "Upgrades the organization's plan type."

      accept [:plan_type]
    end
  end

  policies do
    policy action(:create_org_with_owner) do
      authorize_if actor_absent()
    end

    policy action(:update_org) do
      forbid_unless relates_to_actor_via(:organization_members)
      authorize_if expr(^actor(:role) == :owner || ^actor(:role) == :admin)
    end

    policy action(:change_org_plan) do
      forbid_unless relates_to_actor_via(:organization_members)
      authorize_if actor_attribute_equals(:role, :owner)
    end

    policy action_type(:read) do
      authorize_if relates_to_actor_via(:organization_members)
    end
  end

  validations do
    validate present(:name) do
      where action_is([:create_org_with_owner, :update_org])
      message "Name is required"
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :slug, :string do
      writable? false
    end

    attribute :plan_type, :atom do
      constraints one_of: [:free, :premium, :enterprise]
      default :free
      allow_nil? false
    end

    attribute :can_standard_member_create_project, :boolean, default: true

    timestamps()
  end

  relationships do
    has_many :projects, Tuesday.Projects.Project do
      description "Projects within this organization (tenant)."
      source_attribute :id
      destination_attribute :organization_id
    end

    has_many :organization_members, Tuesday.Workspace.OrganizationMember do
      source_attribute :id
      destination_attribute :organization_id
    end
  end

  calculations do
    calculate :active_project_percentage,
              :float,
              expr(
                if total_projects > 0 do
                  count(projects, query: [filter: expr(status == "active")]) / total_projects *
                    100
                else
                  0.0
                end
              ) do
      description "Percentage of active projects out of total projects."
    end
  end

  aggregates do
    count :total_member_count, :organization_members

    count :active_members, :organization_members do
      description "Count of active members."

      filter expr(status == "active")
    end

    count :total_projects, :projects do
      description "Total number of projects."
    end

    list :project_names, :projects, :name
  end

  identities do
    identity :unique_name, [:name] do
      description "Ensures organization names are globally unique."
      message "An organization with the given name already exists"
    end
  end
end
