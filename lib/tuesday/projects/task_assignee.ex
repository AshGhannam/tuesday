defmodule Tuesday.Projects.TaskAssignee do
  use Ash.Resource,
    domain: Tuesday.Projects,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "task_assignee"
    repo Tuesday.Repo
  end

  resource do
    description """
    TaskAssignee associates a OrganizationMember (not ProjectMember) with a Task.

    Even though, this resource links the OrganizationMember, we want to verify that any
    OrganizationMember related to the Task is already a member of the Project to which the task belongs to.

    For eg., consider the following scenario
    1. Organization ABC has two projects
      a. Project Hello
      b. Project World

    2. Organization ABC has two members
      a. Member A
      b. Member B

    3. Project Hello has only one member "Member A" (from the two members above) through its ProjectMember
    4. Project World has only one member "Member B" (from the two members above) through its ProjectMember

    Given this scenario,
    1. A Task that is belonging to "Project Hello" cannot be assigned to "Member B" (because B doesn't have membership with Project Hello)
    2. A Task that is belonging to "Project World" cannot be assigned to "Member A" (because A doesn't have membership with Project World)


    Currently this contains no additional data other than serving as a join resource but
    potentially this could be expanded to store the role of an OrganizationMember
    for a specific project.
    """
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  multitenancy do
    strategy :attribute
    attribute :organization_id
    global? true
  end

  attributes do
    uuid_primary_key :id

    attribute :assignee_id, :uuid do
      source :organization_member_id
    end

    timestamps()
  end

  relationships do
    belongs_to :organization, Tuesday.Workspace.Organization

    belongs_to :assignee, Tuesday.Workspace.OrganizationMember do
      define_attribute? false
      source_attribute :assignee_id
    end

    belongs_to :task, Tuesday.Projects.Task, allow_nil?: false
  end
end
