defmodule UserInterface.ChoreTest do
  use UserInterface.ModelCase

  alias UserInterface.Chore

  @valid_attrs %{description: "some content", friday: true, member_id: 42, monday: true, name: "some content", once: true, required: true, saturday: true, sunday: true, thrusday: true, tuesday: true, wednesday: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Chore.changeset(%Chore{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Chore.changeset(%Chore{}, @invalid_attrs)
    refute changeset.valid?
  end
end
