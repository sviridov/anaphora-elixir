defmodule Anaphora do
  @vsn "0.0.1"

  @moduledoc """
  Anaphorex main module
  """

  @doc """
  Returns `it` variable defined in user context
  """
  defp it do
    Macro.var(:it, nil)
  end

  @doc """
  Binds the `expression` to `it` (via `case`) in the scope of the `body`.

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
end
