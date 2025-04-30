defmodule Tuesday.ProjectsTest do
  use Tuesday.DataCase

  alias Tuesday.Projects

  describe "create_project" do
    test "forbids creation when org disallows standard member project creation" do
      organization = generate(organization(can_standard_member_create_project: false))
      actor = generate(organization_member(role: :standard, organization_id: organization.id))

      refute Projects.can_create_project?(actor, %{organization_id: organization.id})
    end

    test "allows creation when the actor is an org member and org permits it" do
      organization = generate(organization(can_standard_member_create_project: true))
      actor = generate(organization_member(role: :standard, organization_id: organization.id))

      assert Projects.can_create_project?(actor, %{organization_id: organization.id})
    end

    test "allows creation when the actor is an org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)

      assert Projects.can_create_project?(actor, %{organization_id: organization.id})
    end

    test "forbids creation without actor" do
      actor = nil

      refute Projects.can_create_project?(actor)
    end

    test "forbids creation when the actor is not an org member" do
      %{org_member: actor1, organization: _organization1} = create_org_member()
      %{org_member: _actor2, organization: organization2} = create_org_member()

      refute Tuesday.Projects.can_create_project?(actor1, %{organization_id: organization2.id})
    end
  end

  describe "update_project" do
    test "allows update when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_update_project?(actor, project)
    end

    test "allows update when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_update_project?(actor, project)
    end

    test "forbids update when the actor is not authenticated" do
      actor = nil
      project = generate(project())

      refute Projects.can_update_project?(actor, project)
    end

    test "forbids update when the actor is neither owner nor admin but still a standard project member" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :standard, org_member: actor)

      refute Projects.can_update_project?(actor, project)
    end

    test "allows update when the actor is project owner" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :owner, org_member: actor)

      assert Projects.can_update_project?(actor, project)
    end

    test "allows update when the actor is project admin" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :admin, org_member: actor)

      assert Projects.can_update_project?(actor, project)
    end
  end

  describe "archive_project" do
    test "allows archiving when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_archive_project?(actor, project)
    end

    test "allows archiving when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_archive_project?(actor, project)
    end

    test "forbids archiving when the actor is not authenticated" do
      actor = nil
      project = generate(project())

      refute Projects.can_archive_project?(actor, project)
    end

    test "forbids archiving when the actor is neither owner nor admin but still a standard project member" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :standard, org_member: actor)

      refute Projects.can_archive_project?(actor, project)
    end

    test "allows archiving when the actor is a project owner" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :owner, org_member: actor)

      assert Projects.can_archive_project?(actor, project)
    end

    test "allows archiving when the actor is a project admin" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :admin, org_member: actor)

      assert Projects.can_archive_project?(actor, project)
    end
  end

  describe "add_members" do
    test "allows adding members when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      %{org_member: member} = create_org_member(organization: organization)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "allows adding members when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      %{org_member: member} = create_org_member(organization: organization)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "forbids adding a member when the actor is not authenticated" do
      actor = nil
      %{org_member: member, organization: organization} = create_org_member()
      project = generate(project(organization_id: organization.id))

      refute Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "forbids adding a member when the actor is standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{org_member: member} = create_org_member(organization: organization)
      project = generate(project(organization_id: organization.id))

      refute Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "forbids adding a member who is not an org member even if the actor is owner" do
      %{org_member: actor, organization: organization1} = create_org_member(role: :owner)
      %{org_member: member, organization: _organization2} = create_org_member()
      project = generate(project(organization_id: organization1.id))

      refute Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "forbids adding a member who is not an org member even if the actor is admin" do
      %{org_member: actor, organization: organization1} = create_org_member(role: :admin)
      %{org_member: member, organization: _organization2} = create_org_member()
      project = generate(project(organization_id: organization1.id))

      refute Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "allows adding members when the actor is project owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :owner, org_member: actor)
      %{org_member: member} = create_org_member(organization: organization)

      assert Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "allows adding members when the actor is project admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :admin, org_member: actor)
      %{org_member: member} = create_org_member(organization: organization)

      assert Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end

    test "forbids adding members when the actor is just a project member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :standard, org_member: actor)
      %{org_member: member} = create_org_member(organization: organization)

      refute Projects.can_add_members?(actor, project, %{
               project_members: [
                 %{project_role: :admin, organization_member_id: member.id}
               ]
             })
    end
  end

  describe "update_member" do
    test "allows updating a member when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project: project, project_member: project_member} =
        create_project_member(project_role: :standard, org_member: org_member)

      assert Projects.can_update_member?(actor, project, %{
               project_member: %{project_role: :admin, id: project_member.id}
             })
    end

    test "allows updating a member when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project: project, project_member: project_member} =
        create_project_member(project_role: :standard, org_member: org_member)

      assert Projects.can_update_member?(actor, project, %{
               project_member: %{project_role: :admin, id: project_member.id}
             })
    end

    test "forbids updating a member when the actor is not authenticated" do
      actor = nil
      %{project: project, project_member: project_member} = create_project_member()

      refute Projects.can_update_member?(actor, project, %{
               project_member: %{project_role: :admin, id: project_member.id}
             })
    end

    test "forbids updating a member when the actor is standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project: project, project_member: project_member} =
        create_project_member(project_role: :standard, org_member: org_member)

      refute Projects.can_update_member?(actor, project, %{
               project_member: %{project_role: :admin, id: project_member.id}
             })
    end

    test "allows updating a member when the actor is project owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :owner, org_member: actor)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project_member: project_member} =
        create_project_member(project_role: :standard, project: project, org_member: org_member)

      assert Projects.can_update_member?(actor, project, %{
               project_member: %{project_role: :admin, id: project_member.id}
             })
    end

    test "allows updating a member when the actor is project admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :admin, org_member: actor)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project_member: project_member} =
        create_project_member(project_role: :standard, project: project, org_member: org_member)

      assert Projects.can_update_member?(actor, project, %{
               project_member: %{project_role: :admin, id: project_member.id}
             })
    end

    test "forbids updating a member when the actor is just a project member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :standard, org_member: actor)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project_member: project_member} =
        create_project_member(project_role: :standard, project: project, org_member: org_member)

      refute Projects.can_update_member?(actor, project, %{
               project_member: %{project_role: :admin, id: project_member.id}
             })
    end
  end

  describe "remove_member" do
    test "allows removing a member when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project: project, project_member: project_member} =
        create_project_member(project_role: :standard, org_member: org_member)

      assert Projects.can_remove_member?(actor, project, %{
               project_member: %{id: project_member.id}
             })
    end

    test "allows removing a member when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project: project, project_member: project_member} =
        create_project_member(project_role: :standard, org_member: org_member)

      assert Projects.can_remove_member?(actor, project, %{
               project_member: %{id: project_member.id}
             })
    end

    test "forbids removing a member when the actor is not authenticated" do
      actor = nil
      %{project: project, project_member: project_member} = create_project_member()

      refute Projects.can_remove_member?(actor, project, %{
               project_member: %{id: project_member.id}
             })
    end

    test "forbids removing a member when the actor is standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project: project, project_member: project_member} =
        create_project_member(project_role: :standard, org_member: org_member)

      refute Projects.can_remove_member?(actor, project, %{
               project_member: %{id: project_member.id}
             })
    end

    test "allows removing a member when the actor is project owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :owner, org_member: actor)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project_member: project_member} =
        create_project_member(project_role: :standard, project: project, org_member: org_member)

      assert Projects.can_remove_member?(actor, project, %{
               project_member: %{id: project_member.id}
             })
    end

    test "allows removing a member when the actor is project admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :admin, org_member: actor)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project_member: project_member} =
        create_project_member(project_role: :standard, project: project, org_member: org_member)

      assert Projects.can_remove_member?(actor, project, %{
               project_member: %{id: project_member.id}
             })
    end

    test "forbids removing a member when the actor is just a project member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{project: project} = create_project_member(project_role: :standard, org_member: actor)
      %{org_member: org_member} = create_org_member(organization: organization)

      %{project_member: project_member} =
        create_project_member(project_role: :standard, project: project, org_member: org_member)

      refute Projects.can_remove_member?(actor, project, %{
               project_member: %{id: project_member.id}
             })
    end
  end

  describe "create_task" do
    test "allows creation when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_create_task?(actor, %{project_id: project.id})
    end

    test "allows creation when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      project = generate(project(organization_id: organization.id))

      assert Projects.can_create_task?(actor, %{project_id: project.id})
    end

    test "allows creation when the actor is a project member" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(org_member: actor)

      assert Projects.can_create_task?(actor, %{project_id: project.id})
    end

    test "forbids creation when the actor is not authenticated" do
      actor = nil
      project = generate(project())

      refute Projects.can_create_task?(actor, %{project_id: project.id})
    end

    test "forbids creation when the actor is not a project member but a standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      project = generate(project(organization_id: organization.id))

      refute Projects.can_create_task?(actor, %{project_id: project.id})
    end
  end

  describe "update_task" do
    test "allows update when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_update_task?(actor, task)
    end

    test "allows update when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_update_task?(actor, task)
    end

    test "allows update when the actor is a project member" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(org_member: actor)
      task = generate(task(project_id: project.id))

      assert Projects.can_update_task?(actor, task)
    end

    test "forbids update when the actor is not authenticated" do
      actor = nil
      task = generate(task())

      refute Projects.can_update_task?(actor, task)
    end

    test "forbids update when the actor is not a project member but a standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      refute Projects.can_update_task?(actor, task)
    end
  end

  describe "add_sub_task" do
    test "allows adding a sub-task when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_add_sub_task?(actor, task)
    end

    test "allows adding a sub-task when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_add_sub_task?(actor, task)
    end

    test "allows adding a sub-task when the actor is a project member" do
      %{org_member: actor} = create_org_member(role: :admin)
      %{project: project} = create_project_member(org_member: actor)
      task = generate(task(project_id: project.id))

      assert Projects.can_add_sub_task?(actor, task)
    end

    test "forbids adding a sub-task when the actor is not authenticated" do
      actor = nil
      task = generate(task())

      refute Projects.can_add_sub_task?(actor, task)
    end

    test "forbids adding a sub-task when the actor is not a project member but a standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      refute Projects.can_add_sub_task?(actor, task)
    end
  end

  describe "add_parent_task" do
    test "allows adding a parent task when the actor is an org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_add_parent_task?(actor, task)
    end

    test "allows adding a parent task when the actor is an org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_add_parent_task?(actor, task)
    end

    test "allows adding a parent task when the actor is a project member" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(org_member: actor)
      task = generate(task(project_id: project.id))

      assert Projects.can_add_parent_task?(actor, task)
    end

    test "forbids adding a parent task when the actor is not authenticated" do
      actor = nil
      task = generate(task())

      refute Projects.can_add_parent_task?(actor, task)
    end

    test "forbids adding a parent task when the actor is not a project member but a standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      refute Projects.can_add_parent_task?(actor, task)
    end
  end

  describe "create_comment" do
    test "allows creation when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_create_comment?(actor, %{task_id: task.id})
    end

    test "allows creation when the actor is org admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      assert Projects.can_create_comment?(actor, %{task_id: task.id})
    end

    test "allows creation when the actor is a project member" do
      %{org_member: actor} = create_org_member(role: :standard)
      %{project: project} = create_project_member(org_member: actor)
      task = generate(task(project_id: project.id))

      assert Projects.can_create_comment?(actor, %{task_id: task.id})
    end

    test "forbids creation when the actor is not authenticated" do
      actor = nil
      task = generate(task())

      refute Projects.can_create_comment?(actor, %{task_id: task.id})
    end

    test "forbids creation when the actor is not a project member but a standard org member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))

      refute Projects.can_create_comment?(actor, %{task_id: task.id})
    end
  end

  describe "update_comment" do
    test "allows update when the actor is the comment’s author" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))
      comment = generate(comment(task_id: task.id, author_id: actor.id))

      assert Projects.can_update_comment?(actor, comment)
    end

    test "forbids update when the actor is not authenticated" do
      actor = nil
      comment = generate(comment())

      refute Projects.can_update_comment?(actor, comment)
    end

    test "forbids update when the actor is not the comment’s author" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{org_member: member} = create_org_member(role: :standard, organization: organization)
      project = generate(project(organization_id: organization.id))
      task = generate(task(project_id: project.id))
      comment = generate(comment(task_id: task.id, author_id: member.id))

      refute Projects.can_update_comment?(actor, comment)
    end
  end
end
