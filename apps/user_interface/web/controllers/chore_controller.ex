defmodule UserInterface.ChoreController do
  use UserInterface.Web, :controller

  alias UserInterface.Chore

  plug :scrub_params, "chore" when action in [:create, :update]

  def index(conn, _params) do
    chores = Repo.all(Chore)
    render(conn, "index.html", chores: chores)
  end

  def new(conn, _params) do
    changeset = Chore.changeset(%Chore{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chore" => chore_params}) do
    changeset = Chore.changeset(%Chore{}, chore_params)

    case Repo.insert(changeset) do
      {:ok, _chore} ->
        conn
        |> put_flash(:info, "Chore created successfully.")
        |> redirect(to: chore_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    chore = Repo.get!(Chore, id)
    render(conn, "show.html", chore: chore)
  end

  def edit(conn, %{"id" => id}) do
    chore = Repo.get!(Chore, id)
    changeset = Chore.changeset(chore)
    render(conn, "edit.html", chore: chore, changeset: changeset)
  end

  def update(conn, %{"id" => id, "chore" => chore_params}) do
    chore = Repo.get!(Chore, id)
    changeset = Chore.changeset(chore, chore_params)

    case Repo.update(changeset) do
      {:ok, chore} ->
        conn
        |> put_flash(:info, "Chore updated successfully.")
        |> redirect(to: chore_path(conn, :show, chore))
      {:error, changeset} ->
        render(conn, "edit.html", chore: chore, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    chore = Repo.get!(Chore, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(chore)

    conn
    |> put_flash(:info, "Chore deleted successfully.")
    |> redirect(to: chore_path(conn, :index))
  end
end
