defmodule UserInterface.Repo.Migrations.CreateDevice do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string
      add :member_id, :integer
      add :mac, :string
      add :description, :text
      add :primary, :boolean, default: false

      timestamps
    end

  end
end
