defmodule SortedSetTest do
  use ExUnit.Case, async: true

  alias FingerTree.SortedSet

  test "sorted set primitives" do
    empty_ss = SortedSet.new()

    l = [4, 13, 12, 2, 14, 10, 15, 3, 1, 5, 8]
    assert Enum.sort(l) == l |> Enum.into(empty_ss) |> SortedSet.to_list()

    assert Enum.sort(l) ==
             l
             |> Enum.into(empty_ss)
             |> then(fn ss ->
               l |> Enum.into(ss)
             end)
             |> SortedSet.to_list()

    ss = l |> Enum.into(empty_ss)
    for e <- l, do: assert(SortedSet.member?(ss, e))
    refute SortedSet.member?(ss, 0)
    refute SortedSet.member?(ss, 100)

    Enum.reduce(l, ss, fn e, ss ->
      ss2 = ss |> SortedSet.reject(e)
      refute ss2 |> SortedSet.member?(e)
      ss
    end)

    assert {l, 12, r} = ss |> SortedSet.split(fn e -> e >= 11 end)
    assert SortedSet.to_list(l) == [1, 2, 3, 4, 5, 8, 10]
    assert SortedSet.to_list(r) == [13, 14, 15]

    assert SortedSet.count(ss) == 11

    ss1 = SortedSet.new([1, 3, 5, 7, 9, 11])
    ss2 = SortedSet.new([2, 4, 6, 8, 10, 12])
    assert ss1 |> SortedSet.append(ss2) |> SortedSet.to_list() == Enum.to_list(1..12)

    ss = 1..10 |> Enum.to_list() |> Enum.into(empty_ss)
    {l, x, r} = SortedSet.split_at(ss, 3)
    assert SortedSet.count(l) == 3
    assert x == 4
    assert SortedSet.count(r) == 6

    {_l, x, r} = SortedSet.split_at(ss, 15, :notfound)
    assert SortedSet.empty?(r)
    assert x == :notfound

    for i <- 1..10, do: assert(i == SortedSet.at(ss, i - 1))
    assert :notfound == SortedSet.at(ss, 10, :notfound)
  end

  test "shuffle 2048 test" do
    ss = SortedSet.new()

    l = Enum.to_list(1..2048) |> Enum.shuffle()
    assert Enum.sort(l) == l |> Enum.into(ss) |> SortedSet.to_list()
  end
end
