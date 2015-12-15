defmodule Issues.GithubIssues do
  @user_agent [{"User-agent", "terakilobyte terakilobyte@gmail.com"}]

  def fetch(user, project) do
    issues_url(user, project)
    |> handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.Parser.parse! body
      {:ok, %HTTPoison.Response{status_code: 404}} -> :not_found
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

end
