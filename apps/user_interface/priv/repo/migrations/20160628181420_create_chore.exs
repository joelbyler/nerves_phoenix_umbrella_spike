defmodule UserInterface.Repo.Migrations.CreateChore do
  use Ecto.Migration

  def change do
    create table(:chores) do
      add :name, :string
      add :member_id, :integer
      add :description, :text
      add :required, :boolean, default: false
      add :once, :boolean, default: false
      add :monday, :boolean, default: false
      add :tuesday, :boolean, default: false
      add :wednesday, :boolean, default: false
      add :thrusday, :boolean, default: false
      add :friday, :boolean, default: false
      add :saturday, :boolean, default: false
      add :sunday, :boolean, default: false

      timestamps
    end

  end
end
