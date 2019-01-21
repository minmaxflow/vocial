defmodule VocialWeb.PollControllerTest do 
  use VocialWeb.ConnCase

  test "GET /polls", %{conn: conn} do 
    {:ok, user} = Vocial.Accounts.create_user(%{username: "test", email: "test@test.com", password: "test", password_confirmation: "test"})
    {:ok, poll} = Vocial.Votes.create_poll_with_options(%{title: "Poll 1", user_id: user.id}, ["Choice 1", "Choice 2", "Choice 3"])
    conn = get conn, "/polls"
    assert html_response(conn, 200) =~ poll.title
    Enum.each(poll.options, fn option ->
      assert html_response(conn, 200) =~ option.title 
      assert html_response(conn, 200) =~ "#{option.votes} votes"
    end)

  end
end