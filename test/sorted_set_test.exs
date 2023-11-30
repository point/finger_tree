defmodule SortedSetTest do
  use ExUnit.Case, async: true

  alias FingerTree.SortedSet

  test "sorted set primitives" do
    ss =
      SortedSet.new(fn o1, o2 ->
        cond do
          o1 == o2 -> :eq
          o1 < o2 -> :lt
          :otherwise -> :gt
        end
      end)

    l = [4, 13, 12, 2, 14, 10, 15, 3, 1, 5, 8]
    assert Enum.sort(l) == l |> Enum.into(ss) |> SortedSet.to_list()
  end

  test "shuffle 2048 test" do
    ss =
      SortedSet.new(fn o1, o2 ->
        cond do
          o1 == o2 -> :eq
          o1 < o2 -> :lt
          :otherwise -> :gt
        end
      end)

    l = Enum.to_list(1..2048) |> Enum.shuffle()
    assert Enum.sort(l) == l |> Enum.into(ss) |> SortedSet.to_list()
  end
end
