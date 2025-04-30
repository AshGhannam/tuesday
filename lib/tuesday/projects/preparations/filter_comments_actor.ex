defmodule Tuesday.Projects.Preparations.FilterCommentsForActor do
  use Ash.Resource.Preparation

  @doc """
  Filters comments to only those from tasks the actor can access, if `filter_for_actor?: true` is set in the query context.
  """
  def prepare(query, _opts, context) do
    if Ash.Query.get_argument(query, :filter_for_actor) do
      case context.actor do
        %{id: actor_id} when not is_nil(actor_id) ->
          filter_expr = [
            task: [
              project: [
                project_members: [
                  organization_member: [id: actor_id]
                ]
              ]
            ]
          ]

          Ash.Query.filter(query, ^filter_expr)

        _ ->
          Ash.Query.add_error(query, "Missing or invalid actor for filtering")
      end
    else
      query
    end
  end
end
