defmodule VocialWeb.UserControllerTest do 
  use VocialWeb.ConnCase 

  alias Vocial.Accounts

  test "GET /users/new", %{conn: conn} do 
    conn = get conn, "/users/new"
    assert html_response(conn, 200) =~ "User Signup"
    assert conn.assigns.user.__struct__ == Ecto.Changeset
    assert html_response(conn, 200) =~ "action=\"/users\""
  end

  test "GET /users/:id", %{conn: conn} do 
    user_params = %{"username" => "test", "email" => "test@test.com"}
    with {:ok, user} <- Accounts.create_user(user_params) do 
      conn = get conn, "/users/#{user.id}"
      assert html_response(conn, 200) =~ user.username
    else
      _ -> assert false
    end
  end

  test "POST /users", %{conn: conn} do 
    user_params = %{"username" => "test", "email" => "test@test.com"}
    conn = post conn, "/users", %{"user" => user_params}
    assert redirected_to(conn) =~ "/users/"
  end

end