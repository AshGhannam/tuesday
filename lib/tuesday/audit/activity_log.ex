defmodule Tuesday.Audit.ActivityLog do
  use Ash.Resource,
    domain: Tuesday.Audit,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "activity_logs"
    repo Tuesday.Repo
  end

  resource do
    description """
    `ActivityLog` is to record the activity of `OrganizationMember` for Audit purposes.
    It's related to `OrganizationMember` who is the current actor performing an action that is getting logged.
    """
  end

  actions do
    create :insert_log do
      description "Log a new activity entry. Sets the actor, organization and occured_at automatically."

      accept [:action, :target, :status, :metadata]

      change relate_actor(:actor)
      change set_attribute(:organization_id, actor(:organization_id))
    end

    read :list_logs do
      description "Retrieve activity logs with pagination."

      pagination do
        offset? true
        keyset? true
      end
    end
  end

  multitenancy do
    strategy :attribute
    attribute :organization_id
    global? true
  end

  attributes do
    uuid_primary_key :id

    attribute :action, :string do
      description "The type of action performed (e.g., create, update, delete)."

      allow_nil? false
      constraints max_length: 50
    end

    attribute :target, :string do
      description "The resource affected by the action (e.g., resource_type:resource_id)."

      allow_nil? false
      constraints max_length: 255
    end

    attribute :status, :atom do
      description "The outcome of the action."

      allow_nil? false
      constraints one_of: [:success, :failure]
      default :success
    end

    attribute :metadata, :map do
      description "Additional context like IP address, changed fields, etc."

      default %{}
    end

    attribute :actor_id, :uuid do
      source :organization_member_id
    end

    create_timestamp :occurred_at do
      description "The timestamp when the action took place."

      allow_nil? false
    end
  end

  relationships do
    belongs_to :organization, Tuesday.Workspace.Organization do
      description "The organization (tenant) this activity log belongs to."

      allow_nil? false
    end

    belongs_to :actor, Tuesday.Workspace.OrganizationMember do
      description "The organization member performing the action."

      define_attribute? false
      source_attribute :actor_id
      allow_nil? false
    end
  end
end
