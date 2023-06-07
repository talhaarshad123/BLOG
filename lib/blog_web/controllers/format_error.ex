defmodule BlogWeb.FormatError do


  def format_error_changeset(%Ecto.Changeset{}=changeset) do
    Enum.map(changeset.errors, fn error ->
      {field_name, {reason, _}} = error
      "#{field_name} #{reason}"
    end)
  end

end
