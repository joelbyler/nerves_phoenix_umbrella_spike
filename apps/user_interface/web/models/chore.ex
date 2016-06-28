defmodule UserInterface.Chore do
  use UserInterface.Web, :model

  schema "chores" do
    field :name, :string
    field :member_id, :integer
    field :description, :string
    field :required, :boolean, default: false
    field :once, :boolean, default: false
    field :monday, :boolean, default: false
    field :tuesday, :boolean, default: false
    field :wednesday, :boolean, default: false
    field :thrusday, :boolean, default: false
    field :friday, :boolean, default: false
    field :saturday, :boolean, default: false
    field :sunday, :boolean, default: false

    timestamps
  end

  @required_fields ~w(name member_id description required once monday tuesday wednesday thrusday friday saturday sunday)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
