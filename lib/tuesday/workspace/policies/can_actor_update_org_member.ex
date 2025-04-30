defmodule Tuesday.Checks.CanActorUpdateOrgMember do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    """
    Below are the conditions that must be true to allow updation of a member:
    1. Actor's org_id and the member's org_id are same
    2. Cannot change username unless actor and member are the same
    3. Cannot change role unless actor role is `owner` or `admin` and member is different from actor
    """
  end

  def match?(nil, _, _), do: false

  def match?(
        %{id: actor_id, role: actor_role, organization_id: actor_org_id} = _actor,
        %{changeset: changeset} = _context,
        _opts
      ) do
    member_id = Ash.Changeset.get_data(changeset, :id)
    member_org_id = Ash.Changeset.get_data(changeset, :organization_id)

    # all boolean variables we need to check
    actor_part_of_org_as_member? = actor_org_id == member_org_id
    actor_is_same_as_member? = actor_id == member_id
    is_changing_username? = Ash.Changeset.changing_attribute?(changeset, :username)
    is_changing_role? = Ash.Changeset.changing_attribute?(changeset, :role)
    actor_is_owner_or_admin? = actor_role in [:owner, :admin]

    actor_part_of_org_as_member? and
      ((actor_is_same_as_member? and is_changing_username? and not is_changing_role?) or
         (actor_is_owner_or_admin? and not is_changing_username? and not actor_is_same_as_member?))
  end
end
