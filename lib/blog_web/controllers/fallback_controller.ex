defmodule BlogWeb.FallbackController do

  use BlogWeb, :controller
  import BlogWeb.FormatError


  def call(conn, nil) do
    resp(conn, 404, "NOT FOUND")
  end

  def call(conn, false) do
    resp(conn, 403, "FORBIDAN")
  end

  def call(conn, :error) do
    resp(conn, 403, "FORBIDAN")
  end

  def call(conn, {:error, changeset}) do
    render(conn, :error_handler, error: format_error_changeset(changeset))
  end
end
