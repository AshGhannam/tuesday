defmodule Tuesday.Checks.CanActorInviteMember do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    """
    Below are the conditions that must be true to allow invitation of a member:
    1. Actor's org_id and the intended member's org_id are same
    2. Actor role is either `owner` or `admin`
    """
  end

  def match?(nil, _, _), do: false

  def match?(
        %{role: actor_role, organization_id: actor_org_id} = _actor,
        %{changeset: changeset} = _ctx,
        _opts
      ) do
    member_org_id = Ash.Changeset.get_attribute(changeset, :organization_id)

    actor_org_id == member_org_id and actor_role in [:owner, :admin]
  end
end
