defmodule Tuesday.ProjectViewHistory do
  use Agent

  @max_projects 5

  # Start the Agent
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Mark a Project as viewed
  def view_project(user_id, project_id) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, user_id, [project_id], fn projects ->
        [project_id | projects]
        |> Enum.uniq()
        |> Enum.take(@max_projects)
      end)
    end)
  end

  # Get last 5 viewed Projects for a user
  def get_viewed_projects(user_id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, user_id, [])
    end)
  end
end
