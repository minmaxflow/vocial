defmodule VocialWeb.PollController do 
  use VocialWeb, :controller

  alias Vocial.Votes

  def index(conn, _params) do 
    polls = Votes.list_polls()

    conn 
    |> render("index.html", polls: polls)
  end

  def new(conn, _params) do 
    poll = Votes.new_poll()
    conn
    |> render("new.html", poll: poll)
  end

  def create(conn, %{"poll" => poll_params, "options" => options}) do 
    split_optiosn = String.split(options, ",")
    with {:ok, poll} <- Votes.create_poll_with_options(poll_params, split_optiosn) do 
      conn 
      |> put_flash(:info, "Poll created successfully!")
      |> redirect(to: poll_path(conn, :index))
    end
  end

end