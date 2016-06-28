defmodule UserInterface.Repo.Migrations.CreateDevice do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string
      add :mac, :string
      add :description, :text
      add :primary, :boolean, default: false
      add :member_id, references(:members, on_delete: :nothing)

      timestamps
    end
    create index(:devices, [:member_id])

  end
end
