defmodule Tuesday.Auth.UserTest do
  use Tuesday.DataCase

  alias Tuesday.Auth.User

  describe "register_user" do
    test "fails with empty email" do
      changeset = Ash.Changeset.for_create(User, :register_user, %{email: ""})

      assert_has_error(changeset, fn error ->
        match?(%{message: "Email ID is required"}, error)
      end)
    end

    test "fails with invalid email format" do
      changeset = Ash.Changeset.for_create(User, :register_user, %{email: "invalid-email"})

      assert_has_error(changeset, fn error ->
        match?(%{message: "Email ID is invalid"}, error)
      end)
    end

    test "succeeds with valid email" do
      changeset = Ash.Changeset.for_create(User, :register_user, %{email: "user@example.com"})

      assert changeset.valid?
    end

    test "fails with a duplicate email" do
      generate(user(email: "user@example.com"))

      result =
        Ash.Changeset.for_create(User, :register_user, %{email: "user@example.com"})
        |> Ash.create(authorize?: false)

      assert_has_error(result, fn error ->
        match?(%{message: "A user with the given email already exists."}, error)
      end)
    end
  end

  describe "update_user" do
    test "fails with empty email" do
      user = generate(user())
      changeset = Ash.Changeset.for_update(user, :update_user, %{email: ""})

      assert_has_error(changeset, fn error ->
        match?(%{message: "Email ID is required"}, error)
      end)
    end

    test "fails with invalid email format" do
      user = generate(user())
      changeset = Ash.Changeset.for_update(user, :update_user, %{email: "invalid-email"})

      assert_has_error(changeset, fn error ->
        match?(%{message: "Email ID is invalid"}, error)
      end)
    end

    test "fails with a duplicate email" do
      _user1 = generate(user(email: "one@example.com"))
      user2 = generate(user(email: "two@example.com"))

      result =
        Ash.Changeset.for_update(user2, :update_user, %{email: "one@example.com"})
        |> Ash.update(authorize?: false)

      assert_has_error(result, fn error ->
        match?(%{message: "A user with the given email already exists."}, error)
      end)
    end

    test "succeeds updating the user with valid email" do
      user = generate(user(email: "user@example.com"))

      changeset =
        Ash.Changeset.for_update(user, :update_user, %{email: "updated-user@example.com"})

      assert %{attributes: %{email: %{string: "updated-user@example.com"}}} = changeset
    end
  end
end
