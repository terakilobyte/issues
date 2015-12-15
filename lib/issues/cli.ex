defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle command line parsing dispatch to table generating functions.
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> sort_ascending
    |> pretty_print(count)
  end

  @doc """
  `argv` can be -h or --help, which returns the atom :help
  Otherise, it is a github username, project name[, and the number of entries to format]

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                               aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer count}
      {_, [user, project], _} -> {user, project, @default_count}
      _ -> :help
    end
  end

  def sort_ascending(list_of_issues) do
    Enum.sort list_of_issues, fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
  end

  def pretty_print({:error, reason}, _), do: IO.puts reason
  def pretty_print({:not_found}, _), do: IO.puts "Not found"

  def pretty_print([], _) do
    IO.puts "========================================"
  end

  def pretty_print(_, 0) do
    IO.puts "========================================"
  end

  def pretty_print([head | tail], count) do
    IO.puts """
    ========================================\n
    Opened by: #{head["user"]["login"]}\n
    Opened on: #{head["created_at"]}\n
    Opened for: #{head["body"]}
    """
    pretty_print(tail, count - 1)
  end
end
