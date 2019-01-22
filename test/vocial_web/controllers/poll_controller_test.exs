defmodule VocialWeb.PollControllerTest do 
  use VocialWeb.ConnCase

  setup do 
    conn = build_conn()
    {:ok, user} = Vocial.Accounts.create_user(%{username: "test", email: "test@test.com", password: "test", password_confirmation: "test"})
    {:ok, poll} = Vocial.Votes.create_poll_with_options(%{title: "My New Test Poll", user_id:  user.id}, ["one", "two", "three"])
    {:ok, conn: conn, user: user, poll: poll}
  end

  test "GET /polls", %{conn: conn, user: user} do 
    {:ok, poll} = Vocial.Votes.create_poll_with_options(%{title: "Poll 1", user_id: user.id}, ["Choice 1", "Choice 2", "Choice 3"])
    conn = get conn, "/polls"
    assert html_response(conn, 200) =~ poll.title
    Enum.each(poll.options, fn option ->
      assert html_response(conn, 200) =~ option.title 
      assert html_response(conn, 200) =~ "#{option.votes}"
    end)
  end

  test "GET /polls/new with a logged in user", %{conn: conn, user: user} do 
    conn = login(conn, user) |> get("/polls/new")
    assert html_response(conn, 200) =~ "New Poll"
  end
    
  test "POST /polls with valid data", %{conn: conn, user: user} do 
    conn = login(conn, user)       
           |> post("/polls", %{"poll" => %{"title" => "Test Poll"}, "options" => "One, Two, Three"})
    assert redirected_to(conn) == "/polls"
  end

  test "POST /polls with invalid data", %{conn: conn, user: user} do 
    conn = login(conn, user) |> post("/polls", %{"poll" => %{"title" => nil}, "options" => "One,Two,Three"})
    assert html_response(conn, 302)
    assert redirected_to(conn) == "/polls/new"
  end

  test "GET /polls/new without a logged in user", %{conn: conn} do 
    conn = get(conn, "/polls/new")
    assert redirected_to(conn) == "/"
    assert get_flash(conn, :error) =~ "logged"
  end

  test "POST /polls (with valid data, without logged in user)", %{conn: conn} do 
    conn = post(conn, "/polls", %{"poll" => %{"title" => "Test Poll"}, "options" => "a,b,c"})
    assert redirected_to(conn) == "/"
    assert get_flash(conn,:error) =~ "logged"
  end

  test "GET /options/:id/votes", %{conn: conn, poll: poll} do 
    option = Enum.at(poll.options, 0)
    before_votes = option.votes 
    conn = get(conn, "/options/#{option.id}/vote")
    after_option = Vocial.Repo.get!(Vocial.Votes.Option, option.id)

    assert html_response(conn, 302)
    assert redirected_to(conn) == "/polls"
    assert after_option.votes == before_votes + 1
  end

  defp login(conn, user) do
    conn |> post("/sessions", %{username: user.username, password: user.password})
  end
end