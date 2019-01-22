defmodule VocialWeb.PollController do 
  use VocialWeb, :controller
  alias Vocial.Votes

  plug VocialWeb.VerifyUserSession when action in [:new, :create]

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

  def create(conn, %{"poll" => poll_params, "options" => options, "image_data" => image_data}) do 
    split_optiosn = String.split(options, ",")
    with  user <- get_session(conn, :user),
          poll_params <- Map.put(poll_params, "user_id", user.id),
          {:ok, _poll} <- Votes.create_poll_with_options(poll_params, split_optiosn, image_data) 
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

  def vote(conn, %{"id" => id}) do 
    with {:ok, option} <- Votes.vote_on_option(id) do 
      conn 
      |> put_flash(:info, "Placed a vote for #{option.title}!")
      |> redirect(to: poll_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do 
    with poll <- Votes.get_poll(id) do 
      render(conn, "show.html", poll: poll)
    end
  end

end