defmodule UserInterface.ChoreController do
  use UserInterface.Web, :controller

  alias UserInterface.Chore

  plug :scrub_params, "chore" when action in [:create, :update]
  plug :fetch_member

  def index(conn, _params) do
    chores = Repo.all(Chore)
    render(conn, "index.html", chores: chores)
  end

  def new(conn, _params) do
    changeset = Chore.changeset(%Chore{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chore" => chore_params}) do
    changeset =
      conn.assigns[:member]
      |> build_assoc(:chores)
      |> Chore.changeset(chore_params)
    case Repo.insert(changeset) do
      {:ok, _chore} ->
        conn
        |> put_flash(:info, "Chore created successfully.")
        |> redirect(to: member_chore_path(conn, :index, conn.assigns[:member]))
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
    chore = Repo.get!(assoc(conn.assigns[:member], :chores), id)
    changeset = Chore.changeset(chore, chore_params)
    case Repo.update(changeset) do
      {:ok, chore} ->
        conn
        |> put_flash(:info, "Chore updated successfully.")
        |> redirect(to: member_chore_path(conn, :show, conn.assigns[:member], chore))
      {:error, changeset} ->
        render(conn, "edit.html", chore: chore, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    chore = Repo.get!(assoc(conn.assigns[:member], :chores), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(chore)
    conn
    |> put_flash(:info, "Chore deleted successfully.")
    |> redirect(to: member_chore_path(conn, :index, conn.assigns[:member]))
  end

  defp fetch_member(conn, _opts) do
    case conn.params do
      %{"member_id" => member_id} ->
        member = Repo.get(UserInterface.Member, member_id)
        assign(conn, :member, member)
      _ ->
        conn
    end
  end
end
