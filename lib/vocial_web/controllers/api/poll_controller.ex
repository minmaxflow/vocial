defmodule VocialWeb.Api.PollController do 
  use VocialWeb, :controller

  alias Vocial.Votes

  def index(conn, _params) do 
    polls = Votes.list_most_recent_polls()
    render(conn, "index.json", polls: polls)
  end
end