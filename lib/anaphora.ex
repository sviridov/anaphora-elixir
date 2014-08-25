defmodule Anaphora do
  @vsn "0.0.1"

  @moduledoc """
  The anaphoric macro collection for Elixir
  """

  defmacro __using__(_) do
    quote do
      import Anaphora
    end
  end

  ## Returns the `it` variable defined in user context
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
  Works like `if`, except that result of the `condition` is bound to `it` (via `alet`) for the
  scope of the then and else `clauses`

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

  @doc """
  Works like `cond`, except that result of each `condition` is bound to `it` (via `alet`) for the
  scope of the corresponding `body`

  ## Examples

     iex> Anaphora.acond do
     ...>   :acond_test -> it
     ...> end
     :acond_test

     iex> Anaphora.acond do
     ...>   1 + 2 == 4 -> :never
     ...>   false -> :never
     ...>   2 * 2 + 2 -> it / 2
     ...>   true -> :never
     ...> end
     3.0

    iex> Anaphora.acond do
    ...>   false -> :never
    ...> end
    nil

  """
  defmacro acond(clauses)
  defmacro acond(do: []), do: nil
  defmacro acond(do: clauses) do
    {:->, _context, [[condition], body]} = hd(clauses)

    quote do
      Anaphora.aif unquote(condition) do
        unquote(body)
      else
        Anaphora.acond do
          unquote(tl(clauses))
        end
      end
    end
  end

  @doc """
  Works like `case`, except that result of the `key` expression is bound to `it` (via `alet`) for the
  scope of the `cases`

  ## Examples

     iex> Anaphora.acase :acase_test do
     ...>   :acase_test -> it
     ...> end
     :acase_test

     iex> Anaphora.acase [1, 2, 3] do
     ...>   {a, b, c} -> :never
     ...>   [1 | tale] -> it -- tale
     ...>   _ -> :never
     ...> end
     [1]

     iex> try do
     ...>   Anaphora.acase true do
     ...>     false -> :never
     ...>   end
     ...> rescue
     ...>   _e in CaseClauseError -> :error
     ...> end
     :error

  """
  defmacro acase(key, do: cases) do
    quote do
      Anaphora.alet unquote(key) do
        case unquote(it) do
          unquote(cases)
        end
      end
    end
  end

  @doc """
  Evaluates each `clause` one at a time and binds result to `it`. As soon as any `clause`
  evaluates to `nil` (or `false`), and returns `nil` without evaluating the remaining
  `clauses`. If all `clauses` but the last evaluate to true values, `aand` returns the
  results produced by evaluating the last `clause`

  ## Examples

     iex> Anaphora.aand do
     ...> end
     true

     iex> Anaphora.aand do
     ...>   :aand_test
     ...> end
     :aand_test

     iex> Anaphora.aand do
     ...>   2 + 3
     ...>   1 + it + 4
     ...>   it * 20
     ...> end
     200

     iex> Anaphora.aand do
     ...>   1 == 2
     ...>   !it
     ...> end
     nil

  """
  defmacro aand(clauses)
  defmacro aand(do: nil), do: true
  defmacro aand(do: {:__block__, _context, clauses}) do
    clauses |> Enum.reverse |> Enum.reduce(&expand_aand_clause/2)
  end
  defmacro aand(do: expression), do: expression

  defp expand_aand_clause(clause, body) do
    quote do
      Anaphora.aif unquote(clause), do: unquote(body)
    end
  end

  @doc """
  Works like `fn`, except that anonymous function is bind to `it` (via `blood magic`)

  ## Examples

     iex> fact = Anaphora.afn do
     ...>   0 -> 1
     ...>   1 -> 1
     ...>   n when n > 0 -> n * it.(n - 1)
     ...> end
     ...> fact.(5)
     120

     iex> fib = Anaphora.afn do
     ...>   0 -> 1
     ...>   1 -> 1
     ...>   n when n > 0 -> it.(n - 1) + it.(n - 2)
     ...> end
     ...> Enum.map(1..7, fib)
     [1, 2, 3, 5, 8, 13, 21]

     iex> (Anaphora.afn do
     ...>   x, y when x > 0 -> x + it.(x - 1, y)
     ...>   0, y when y > 0 -> y + it.(0, y - 1)
     ...>   0, 0 -> 0
     ...> end).(2, 4)
     13

  """
  defmacro afn(do: definitions) do
    ys = generate_z_combinator_ys(hd(definitions))

    # λx.f (λys.((x x) ys))
    lambda_x = quote do: fn x -> f.(fn unquote_splicing(ys) -> (x.(x)).(unquote_splicing(ys)) end) end

    lambda_f = quote do: fn f -> (unquote(lambda_x)).(unquote(lambda_x)) end
    lambda_it = quote do: fn unquote(it) -> unquote({:fn, [], definitions}) end

    quote do: (unquote(lambda_f)).(unquote(lambda_it))
  end

  defp generate_z_combinator_ys({:->, _context, [arguments, _body]}) do
    next_y = fn n -> Macro.var(String.to_atom("y#{n}"), __MODULE__) end

    Enum.map(1..number_of_afn_arguments(arguments), next_y)
  end

  defp number_of_afn_arguments([{:when, _context, arguments}]) do
    Enum.count(arguments) - 1
  end

  defp number_of_afn_arguments(arguments) do
    Enum.count(arguments)
  end
end
