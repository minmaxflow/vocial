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
    with  user <- get_session(conn, :user),
          poll_params <- Map.put(poll_params, "user_id", user.id),
          {:ok, _poll} <- Votes.create_poll_with_options(poll_params, split_optiosn) 
          do 
            conn 
            |> put_flash(:info, "Poll created successfully!")
            |> redirect(to: poll_path(conn, :index))
          else 
            {:error, _poll} -> 
                    conn 
                    |> put_flash(:error, "Error creating poll!")
                    |> redirect(to: poll_path(conn, :new))
          end
  end

end