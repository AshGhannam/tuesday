defmodule Tuesday.Projects.ProjectMember do
  use Ash.Resource,
    domain: Tuesday.Projects,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "project_members"
    repo Tuesday.Repo
  end

  resource do
    description """
    ProjectMember associates a OrganizationMember with a Project.

    OrganizationMember's organization_id and Project's organization_id should be same
    to be added to this ProjectMember. This ensures only the members of the organization
    are added to the projects in the organization.
    """
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: [:project_role, :organization_member_id, :project_id, :organization_id],
      update: :*
    ]
  end

  multitenancy do
    strategy :attribute
    attribute :organization_id
    global? true
  end

  attributes do
    uuid_primary_key :id

    attribute :project_role, :atom do
      description "Role of the associated member in the current organization."
      constraints one_of: [:owner, :admin, :standard]
      default :standard
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :organization, Tuesday.Workspace.Organization
    belongs_to :organization_member, Tuesday.Workspace.OrganizationMember, allow_nil?: false
    belongs_to :project, Tuesday.Projects.Project, allow_nil?: false
  end

  aggregates do
    first :organization_role, :organization_member, :role
    first :username, :organization_member, :username
  end

  identities do
    identity :unique_membership, [:organization_member_id, :project_id] do
      description "Ensures project memberships are unique."
      message "Membership already exists."
    end
  end
end
