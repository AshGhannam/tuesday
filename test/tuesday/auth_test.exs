defmodule Tuesday.AuthTest do
  use Tuesday.DataCase

  alias Tuesday.Auth

  describe "register_user" do
    test "allows registration for anonymous users" do
      assert Auth.can_register_user?(nil)
    end

    test "forbids registration for authenticated users" do
      actor = %{id: "dummy-actor-id"}
      refute Auth.can_register_user?(actor)
    end
  end

  describe "update_user" do
    test "allows update when the actor is the user themselves" do
      %{user: user, org_member: actor} = create_org_member()

      assert Auth.can_update_user?(actor, user)
    end

    test "forbids update when the actor is not authenticated" do
      user = generate(user())
      actor = nil

      refute Auth.can_update_user?(actor, user)
    end

    test "forbids update when the actor is a different user" do
      %{user: user1, org_member: _actor1} = create_org_member()
      %{user: _user2, org_member: actor2} = create_org_member()

      refute Auth.can_update_user?(actor2, user1)
    end
  end
end
