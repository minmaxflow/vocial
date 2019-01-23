defmodule VocialWeb.PollController do 
  use VocialWeb, :controller
  alias Vocial.Votes

  plug VocialWeb.VerifyUserSession when action in [:new, :create]

  def index(conn, params) do 
    %{"page" => page, "per_page" => per_page} = normalize_paging_params(params)
    IO.inspect %{"page" => page, "per_page" => per_page}
    polls = Votes.list_most_recent_polls(page, per_page)
    opts = paging_options(polls, page, per_page)
    IO.inspect opts
    conn 
    |> render("index.html", polls: polls, opts: opts)
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
  def create(conn, %{"poll" => _poll_params, "options" => _options} = params) do 
    create(conn, Map.put(params, "image_data", nil))
  end

  def vote(conn, %{"id" => id}) do 
    voter_ip = conn.remote_ip 
               |> Tuple.to_list()
               |> Enum.join(".")
    with {:ok, option} <- Votes.vote_on_option(id, voter_ip) 
    do 
      conn 
      |> put_flash(:info, "Placed a vote for #{option.title}!")
      |> redirect(to: poll_path(conn, :index))
    else
      _ -> conn 
           |> put_flash(:error, "Could not vote!") 
           |> redirect(to: poll_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do 
    with poll <- Votes.get_poll(id) do 
      render(conn, "show.html", poll: poll)
    end
  end

  defp normalize_paging_params(params) do
    %{"page" => 1, "per_page" => 25}
    |> Map.merge(params)
    |> paging_params()
  end

  defp paging_options(polls, page, per_page) do
    %{
      include_next_page: (Enum.count(polls) >= per_page),
      include_prev_page: (page > 0),
      page: page + 1,
      per_page: per_page
    }
  end  

  defp paging_params(%{"page" => page, "per_page" => per_page}) do 
    page = case is_binary(page) do 
      true -> String.to_integer(page)
      _ -> page 
    end

    per_page = case is_binary(per_page) do 
      true -> String.to_integer(per_page)
      _ -> per_page
    end

    %{"page" => page - 1, "per_page" => per_page}
  end

end