defmodule Tuesday.Checks.CanActorDeactivateOrgMember do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    """
    Below are the conditions that must be true to deactivate an organization member:
    1. Actor's org_id and the member's org_id are same
    2. Admin actor cannot deactivate an owner organization member
    3. Organization Member actor cannot deactivate any organization member without admin or owner role
    4. Actor cannot self deactivate
    """
  end

  def match?(nil, _, _), do: false

  def match?(
        %{id: actor_id, role: actor_role, organization_id: actor_org_id} = _actor,
        %{changeset: changeset} = _context,
        _opts
      ) do
    member_id = Ash.Changeset.get_data(changeset, :id)
    member_role = Ash.Changeset.get_data(changeset, :role)
    member_org_id = Ash.Changeset.get_data(changeset, :organization_id)

    # all boolean variables we need to check
    actor_part_of_org_as_member? = actor_org_id == member_org_id
    is_actor_owner_or_admin? = actor_role in [:owner, :admin]
    is_actor_admin? = actor_role == :admin
    is_member_owner? = member_role == :owner

    is_attempting_self_deactivation? = actor_id == member_id

    actor_part_of_org_as_member? and
      is_actor_owner_or_admin? and
      not is_attempting_self_deactivation? and
      not (is_actor_admin? and is_member_owner?)
  end
end
