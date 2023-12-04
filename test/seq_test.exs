defmodule SeqTest do
  use ExUnit.Case, async: true

  alias FingerTree.Seq

  test "seq primitives" do
    seq = [1, 2, 3, 4] |> Enum.into(Seq.new())

    assert [1, 2, 3, 4] = seq |> Seq.to_list()

    assert [1, 2, 3, 4] = Seq.new(1..4) |> Seq.to_list()

    assert 1 == Seq.first(seq)
    assert [2, 3, 4] = seq |> Seq.rest() |> Seq.to_list()

    assert 4 == Seq.last(seq)
    assert [1, 2, 3] = seq |> Seq.butlast() |> Seq.to_list()

    assert [0, 1, 2, 3, 4] = seq |> Seq.cons(0) |> Seq.to_list()
    assert [1, 2, 3, 4, 5] = seq |> Seq.conj(5) |> Seq.to_list()

    assert [1, 2, 3, 4, 5, 6, 7, 8] = seq |> Seq.append(Seq.new([5, 6, 7, 8])) |> Seq.to_list()

    assert {l, 3, r} = Seq.split(seq, fn pos -> pos >= 3 end)
    assert [1, 2] = Seq.to_list(l)
    assert [4] = Seq.to_list(r)

    assert 4 = Seq.count(seq)

    assert [] = Seq.take(seq, 0) |> Seq.to_list()
    assert [1] = Seq.take(seq, 1) |> Seq.to_list()
    assert [1, 2, 3, 4] = Seq.take(seq, 10) |> Seq.to_list()
    assert [4] = Seq.take(seq, -1) |> Seq.to_list()
    assert [1, 2, 3, 4] = Seq.take(seq, -4) |> Seq.to_list()
    assert [1, 2, 3, 4] = Seq.take(seq, -10) |> Seq.to_list()

    assert [1, 2, 3, 4] = Seq.drop(seq, 0) |> Seq.to_list()
    assert [1, 2, 3] = Seq.drop(seq, -1) |> Seq.to_list()
    assert [] = Seq.drop(seq, -10) |> Seq.to_list()
    assert [2, 3, 4] = Seq.drop(seq, 1) |> Seq.to_list()
    assert [] = Seq.drop(seq, 10) |> Seq.to_list()

    assert 1 == Seq.at(seq, 0)
    assert 4 == Seq.at(seq, 3)
    assert :notfound == Seq.at(seq, 4, :notfound)
  end

  test "seq enumerable interface" do
    seq = [1, 2, 3, 4] |> Enum.into(Seq.new())

    assert 4 = Enum.count(seq)
    assert [2, 4, 6, 8] = Enum.map(seq, fn e -> e * 2 end)
    assert [2, 3, 4] = Enum.slice(seq, 1..10)
    assert [1, 2] = Enum.slice(seq, 0..1)
  end

  test "indices after drop" do
    seq = Seq.new([10, 20, 30, 40])
    s2 = Seq.drop(seq, 1)

    {left_s, 30, _} = Seq.split(s2, fn pos -> pos >= 2 end)
    assert [20] = Seq.to_list(left_s)
  end
end
