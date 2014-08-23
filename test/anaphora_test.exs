defmodule AnaphoraTest do
  use ExUnit.Case
  use Anaphora

  test "__using__" do
    assert(acond do
      2 < 1 -> :never
      "Test " -> it <> "__using__"
      1 < 2 -> :never
    end == "Test __using__")
  end

  doctest Anaphora
end
