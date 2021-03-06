defmodule VocialWeb.ErrorView do
  use VocialWeb, :view

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end

  def render("invalid_api_key.json", _assigns) do 
    %{message: "Invalid API Key"}
  end

  def render("404.json", _assigns) do 
    %{message: "Resource not found"}
  end

  def render("500.json", _assigns) do 
    %{message: "An unhandled exception has occurred"}
  end

end
