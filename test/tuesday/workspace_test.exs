defmodule Tuesday.WorkspaceTest do
  use Tuesday.DataCase

  alias Tuesday.Workspace

  describe "create_org_with_owner" do
    test "allows creation for anonymous users" do
      assert Workspace.can_create_org_with_owner?(nil, %{name: "devCarrots"})
    end

    test "forbids creation for authenticated users" do
      actor = %{id: "dummy-actor-id"}
      refute Workspace.can_create_org_with_owner?(actor, %{name: "devCarrots"})
    end
  end

  describe "update_org" do
    test "allows update when the actor is the organization owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)

      assert Workspace.can_update_org?(actor, organization)
    end

    test "allows update when the actor is the organization admin" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)

      assert Workspace.can_update_org?(actor, organization)
    end

    test "forbids update when the actor is not authenticated" do
      actor = nil
      organization = generate(organization())

      refute Workspace.can_update_org?(actor, organization)
    end

    test "forbids update when the actor is the standard member of the organization" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)

      refute Workspace.can_update_org?(actor, organization)
    end
  end

  describe "change_org_plan" do
    test "allows plan change when the actor is the organization owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)

      assert Workspace.can_change_org_plan?(actor, organization)
    end

    test "forbids plan change when the actor is not authenticated" do
      actor = nil
      organization = generate(organization())

      refute Workspace.can_change_org_plan?(actor, organization)
    end

    test "forbids plan change when the actor is a standard member of the organization" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)

      refute Workspace.can_change_org_plan?(actor, organization)
    end

    test "forbids plan change when the actor is admin member of the organization" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)

      refute Workspace.can_change_org_plan?(actor, organization)
    end
  end

  describe "invite_org_member" do
    test "allows an owner actor to invite members to their organization" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)

      assert Workspace.can_invite_org_member?(actor, %{organization_id: organization.id})
    end

    test "allows an admin actor to invite members to their organization" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)

      assert Workspace.can_invite_org_member?(actor, %{organization_id: organization.id})
    end

    test "forbids invitation when the actor is not authenticated" do
      actor = nil
      refute Workspace.can_invite_org_member?(actor)
    end

    test "forbids invitation when the actor is not part of the organization they invite" do
      # owners and admins are the only people who can invite members
      # so, we're creating two actors with two different roles in two different organizations
      %{org_member: actor1, organization: organization1} = create_org_member(role: :owner)
      %{org_member: actor2, organization: organization2} = create_org_member(role: :admin)

      # making sure that they cannot invite/create member of different organizations
      refute Workspace.can_invite_org_member?(actor1, %{organization_id: organization2.id})
      refute Workspace.can_invite_org_member?(actor2, %{organization_id: organization1.id})
    end

    test "forbids invitation when the actor is a standard member of the organization" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)

      refute Workspace.can_invite_org_member?(actor, %{organization_id: organization.id})
    end
  end

  describe "update_org_member" do
    test "allows an owner to update role of the member of the same organization as actor" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      %{org_member: member} = create_org_member(role: :standard, organization: organization)

      assert Workspace.can_update_org_member?(actor, member, %{role: :admin})
    end

    test "allows an admin to update role of the member of the same organization as actor" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      %{org_member: member} = create_org_member(role: :standard, organization: organization)

      assert Workspace.can_update_org_member?(actor, member, %{role: :admin})
    end

    test "allows the actor to update their username" do
      actor = member = generate(organization_member(username: "devy"))

      assert Workspace.can_update_org_member?(actor, member, %{username: "chaaru"})
    end

    test "forbids the standard role actor to update their role" do
      actor = member = generate(organization_member(role: :standard))

      refute Workspace.can_update_org_member?(actor, member, %{role: :admin})
    end

    test "forbids updates to username by any other organization member" do
      organization = generate(organization())
      %{org_member: owner_actor} = create_org_member(role: :owner, organization: organization)
      %{org_member: admin_actor} = create_org_member(role: :admin, organization: organization)

      %{org_member: standard_actor} =
        create_org_member(role: :standard, organization: organization)

      %{org_member: member} = create_org_member(organization: organization)

      refute Workspace.can_update_org_member?(owner_actor, member, %{
               username: "updated-username"
             })

      refute Workspace.can_update_org_member?(admin_actor, member, %{
               username: "updated-username"
             })

      refute Workspace.can_update_org_member?(standard_actor, member, %{
               username: "updated-username"
             })
    end

    test "forbids update when the actor is not authenticated" do
      actor = nil
      member = generate(organization_member())

      refute Workspace.can_update_org_member?(actor, member)
    end

    test "forbids update when the actor is not part of organization of the member" do
      %{org_member: actor, organization: _organization1} = create_org_member()
      %{org_member: member, organization: _organization2} = create_org_member()

      refute Workspace.can_update_org_member?(actor, member)
    end
  end

  describe "deactivate_org_member" do
    test "allows deactivation when the actor is org owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :owner)
      %{org_member: admin_member} = create_org_member(role: :admin, organization: organization)

      %{org_member: standard_member} =
        create_org_member(role: :standard, organization: organization)

      assert Workspace.can_deactivate_org_member?(actor, admin_member)
      assert Workspace.can_deactivate_org_member?(actor, standard_member)
    end

    test "allows deactivation when the actor is org admin and when member isn't owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      %{org_member: admin_member} = create_org_member(role: :admin, organization: organization)

      %{org_member: standard_member} =
        create_org_member(role: :standard, organization: organization)

      assert Workspace.can_deactivate_org_member?(actor, admin_member)
      assert Workspace.can_deactivate_org_member?(actor, standard_member)
    end

    test "forbids deactivation when the actor is not authenticated" do
      actor = nil
      member = generate(organization_member())

      refute Workspace.can_deactivate_org_member?(actor, member)
    end

    test "forbids deactivation when attempting self deactivation" do
      actor = member = generate(organization_member())

      refute Workspace.can_deactivate_org_member?(actor, member)
    end

    test "forbids deactivation of org member when the actor is standard member" do
      %{org_member: actor, organization: organization} = create_org_member(role: :standard)
      %{org_member: member} = create_org_member(organization: organization)

      refute Workspace.can_deactivate_org_member?(actor, member)
    end

    test "forbids admin from deactivating owner" do
      %{org_member: actor, organization: organization} = create_org_member(role: :admin)
      %{org_member: member} = create_org_member(role: :owner, organization: organization)

      refute Workspace.can_deactivate_org_member?(actor, member)
    end
  end
end
