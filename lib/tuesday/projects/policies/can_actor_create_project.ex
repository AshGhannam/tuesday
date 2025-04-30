defmodule Tuesday.Checks.CanActorCreateTask do
  use Ash.Policy.SimpleCheck

  require Ash.Query
  alias Tuesday.Projects.ProjectMember

  def describe(_) do
    """
    At least one of the following conditions must be true to authorize creating a task:
    1. The actor's role is `:owner`.
    2. The actor's role is `:admin`.
    3. The actor's role is `:member` and the actor is a member of the project associated with the task.
    """
  end

  def match?(nil, _, _), do: false

  def match?(
        %{role: actor_role, id: actor_id} = _actor,
        %{changeset: changeset},
        _opts
      ) do
    if actor_role in [:owner, :admin] do
      true
    else
      project_id = Ash.Changeset.get_attribute(changeset, :project_id)

      result =
        Ash.Query.filter(
          ProjectMember,
          project_id == ^project_id and organization_member_id == ^actor_id
        )
        |> Ash.read_one()

      case result do
        {:ok, nil} ->
          false

        {:ok, _record} ->
          true

        _error ->
          false
      end
    end
  end
end
