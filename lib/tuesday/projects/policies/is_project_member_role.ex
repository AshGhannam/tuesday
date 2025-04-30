defmodule Tuesday.Checks.IsProjectMemberRole do
  use Ash.Policy.SimpleCheck

  require Ash.Query
  alias Tuesday.Projects.ProjectMember

  def describe(_) do
    """
      Checks if the project member role is the same as the given role
    """
  end

  def match?(nil, _ctx, _opts), do: false

  def match?(
        %{id: actor_id} = _actor,
        %{changeset: changeset},
        opts
      ) do
    project_id = Ash.Changeset.get_attribute(changeset, :id)

    result =
      Ash.Query.filter(ProjectMember, organization_member_id: actor_id, project_id: project_id)
      |> Ash.read_one()

    case result do
      {:ok, nil} ->
        false

      {:ok, project_member} ->
        role = Keyword.get(opts, :role)
        project_member.project_role == role

      _ ->
        false
    end
  end
end
