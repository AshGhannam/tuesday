defmodule Tuesday.Checks.ActorCreateProject do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    """
      Base condition: Actor's org_id and the intended project's org_id are same

      This base condition is mandatory for all the other checks.

      In addition to the base condition bring true, at least one of the following conditions
      must be true to allow creating project:
      1. Actor role is `:owner`
      2. Actor role is `:admin`
      3. Actor role is `:standard` and Actor organization's `can_standard_member_create_project` is true
    """
  end

  def match?(nil, _, _), do: false

  def match?(
        %{role: actor_role, organization_id: actor_org_id} = actor,
        %{changeset: changeset},
        _opts
      ) do
    project_org_id = Ash.Changeset.get_attribute(changeset, :organization_id)
    org = Ash.get!(Tuesday.Workspace.Organization, actor_org_id, actor: actor)
    can_standard_member_create_project = org.can_standard_member_create_project

    allow_project_creation?(
      actor_role,
      actor_org_id,
      project_org_id,
      can_standard_member_create_project
    )
  end

  defp allow_project_creation?(:owner, org_id, org_id, _), do: true
  defp allow_project_creation?(:admin, org_id, org_id, _), do: true
  defp allow_project_creation?(:standard, org_id, org_id, true), do: true
  defp allow_project_creation?(_, _, _, _), do: false
end
