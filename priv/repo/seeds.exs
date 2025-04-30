import Tuesday.Generator
require Ash.Query

organizations = generate_many(organization(), 3)
users_per_org = 1..7

# Create users & memberships for the created organizations
organizations
|> Enum.each(fn org ->
  for _i <- users_per_org do
    user = generate(user())
    generate(organization_member(user_id: user.id, organization_id: org.id))
  end
end)

common_users = generate_many(user(), 3)
[org1, org2, org3] = organizations

common_users
|> Enum.each(fn user ->
  generate(organization_member(user_id: user.id, organization_id: org1.id))
  generate(organization_member(user_id: user.id, organization_id: org2.id))
  generate(organization_member(user_id: user.id, organization_id: org3.id))
end)

# Create projects and project members for the created organizations
organizations
|> Enum.each(fn org ->
  org_members =
    Tuesday.Workspace.OrganizationMember
    |> Ash.Query.filter(organization_id: org.id)
    |> Ash.read!(authorize?: false)

  # For each organization, create three projects
  Enum.each(1..3, fn _ ->
    project_members = Enum.take_random(org_members, Enum.random(3..5))

    project = generate(project(organization_id: org.id))

    # Assigning members to current project
    Enum.each(project_members, fn project_member ->
      generate(project_member(organization_member_id: project_member.id, project_id: project.id))
    end)

    # Creating random number of tasks for the project
    tasks = generate_many(task(project_id: project.id), Enum.random(10..15))

    # Creating random number of child tasks for random tasks
    child_tasks =
      Enum.take_random(tasks, Enum.random(5..10))
      |> Enum.map(fn task ->
        generate_many(
          child_task(parent_task_id: task.id, start_date: task.start_date),
          Enum.random(1..7)
        )
      end)
      |> List.flatten()

    # Assigning task to one to max three project members
    tasks
    |> Enum.each(fn task ->
      Enum.take_random(project_members, Enum.random(1..3))
      |> Enum.each(fn project_member ->
        generate(task_assignee(task_id: task.id, assignee_id: project_member.id))
      end)
    end)

    # Creating comment for each task
    tasks
    |> Enum.each(fn task ->
      Enum.take_random(project_members, Enum.random(1..3))
      |> Enum.each(fn project_member ->
        generate_many(
          comment(task_id: task.id, author_id: project_member.id),
          Enum.random(1..3)
        )
      end)
    end)

    # Creating comment for all child tasks
    child_tasks
    |> Enum.each(fn task ->
      Enum.take_random(project_members, Enum.random(1..3))
      |> Enum.each(fn project_member ->
        generate_many(
          comment(task_id: task.id, member_id: project_member.id),
          Enum.random(1..3)
        )
      end)
    end)
  end)
end)
