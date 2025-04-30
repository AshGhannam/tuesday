defmodule Tuesday.Checks.CanActorCreateComment do
  use Ash.Policy.SimpleCheck

  require Ash.Query
  alias Tuesday.Projects.Task

  def describe(_) do
    """
    At least one of the following conditions must be true to authorize creating a comment:
    1. The actor's role is `:owner`.
    2. The actor's role is `:admin`.
    3. The actor's role is `:standard` and the actor is a member of the project associated with the comment through task.
    """
  end

  def match?(nil, _, _), do: false

  def match?(
        %{role: actor_role} = actor,
        %{changeset: changeset},
        _opts
      ) do
    if actor_role in [:owner, :admin] do
      true
    else
      task_id = Ash.Changeset.get_attribute(changeset, :task_id)
      task = Ash.get(Task, task_id, actor: actor)

      case task do
        {:ok, _task} ->
          true

        {:error, _error} ->
          false
      end
    end
  end
end
