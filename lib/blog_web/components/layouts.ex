defmodule BlogWeb.Layouts do
  use BlogWeb, :html
  # use Phoenix.VerifiedRoutes, router: BlogWeb.Router, endpoint: BlogWeb.Endpoint

  embed_templates "layouts/*"
end
