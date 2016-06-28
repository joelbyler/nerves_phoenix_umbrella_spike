defmodule UserInterface.DeviceController do
  use UserInterface.Web, :controller

  alias UserInterface.Device

  plug :scrub_params, "device" when action in [:create, :update]
  plug :fetch_member

  def index(conn, %{"member_id" => member_id}) do
    devices = Repo.all(from d in Device, where: d.member_id == ^member_id)
    render(conn, "index.html", devices: devices)
  end

  def new(conn, _params) do
    changeset = Device.changeset(%Device{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"device" => device_params}) do
    changeset =
      conn.assigns[:member]
      |> build_assoc(:devices)
      |> Device.changeset(device_params)
    case Repo.insert(changeset) do
      {:ok, _device} ->
        conn
        |> put_flash(:info, "Device created successfully.")
        |> redirect(to: member_device_path(conn, :index, conn.assigns[:member]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    device = Repo.get!(Device, id)
    render(conn, "show.html", device: device)
  end

  def edit(conn, %{"id" => id}) do
    device = Repo.get!(Device, id)
    changeset = Device.changeset(device)
    render(conn, "edit.html", device: device, changeset: changeset)
  end

  def update(conn, %{"id" => id, "device" => device_params}) do
    device = Repo.get!(assoc(conn.assigns[:member], :devices), id)
    changeset = Device.changeset(device, device_params)
    case Repo.update(changeset) do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device updated successfully.")
        |> redirect(to: member_device_path(conn, :show, conn.assigns[:member], device))
      {:error, changeset} ->
        render(conn, "edit.html", device: device, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    device = Repo.get!(assoc(conn.assigns[:member], :devices), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(device)
    conn
    |> put_flash(:info, "Device deleted successfully.")
    |> redirect(to: member_device_path(conn, :index, conn.assigns[:member]))
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
