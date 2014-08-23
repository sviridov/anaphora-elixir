defmodule Anaphora do
  @vsn "0.0.1"

  @moduledoc """
  Anaphorex main module
  """

  @doc """
  Returns the `it` variable defined in user context
  """
  defp it do
    Macro.var(:it, nil)
  end

  @doc """
  Binds the `expression` to `it` (via `case`) in the scope of the `body`

  ## Examples

     iex> Anaphora.alet 2 * 2 + 2, do: it / 2
     3.0

     iex> Anaphora.alet tl([1, 2, 3]) do
     ...>   hd(it) # do some staff
     ...>   tl(it)
     ...> end
     [3]

  """
  defmacro alet(expression, do: body) do
    quote do
      case unquote(expression) do
        unquote(it) -> unquote(body)
      end
    end
  end

  @doc """
  Like `if`, except binds the result of the `condition` to `it` (via `alet`) for
  the scope of the then and else `clauses`

  ## Examples

     iex> Anaphora.aif :aif_test, do: it
     :aif_test

     iex> Anaphora.aif 2 * 2 + 2 do
     ...>   it / 2
     ...> else
     ...>   :never
     ...> end
     3.0

     iex> Anaphora.aif 1 == 2, do: :never, else: it
     false
  """
  defmacro aif(condition, clauses) do
    quote do
      Anaphora.alet unquote(condition) do
        if(unquote(it), unquote(clauses))
      end
    end
  end
end
