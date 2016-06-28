defmodule UserInterface.Repo.Migrations.CreateChore do
  use Ecto.Migration

  def change do
    create table(:chores) do
      add :name, :string
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
      add :member_id, references(:members, on_delete: :nothing)

      timestamps
    end
    create index(:chores, [:member_id])

  end
end
