defmodule UserInterface.DeviceTest do
  use UserInterface.ModelCase

  alias UserInterface.Device

  @valid_attrs %{description: "some content", mac: "some content", name: "some content", primary: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Device.changeset(%Device{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Device.changeset(%Device{}, @invalid_attrs)
    refute changeset.valid?
  end
end
