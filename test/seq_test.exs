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

    assert [0, 1, 2, 3, 4] == Seq.new(1..4) |> Seq.insert_at(0, 0) |> Seq.to_list()
    assert [1, 2, 0, 3, 4] == Seq.new(1..4) |> Seq.insert_at(2, 0) |> Seq.to_list()
    assert [1, 2, 3, 0, 4] == Seq.new(1..4) |> Seq.insert_at(3, 0) |> Seq.to_list()
    assert [1, 2, 3, 4, 0] == Seq.new(1..4) |> Seq.insert_at(4, 0) |> Seq.to_list()
    assert [1, 2, 3, 0] == Seq.new(1..3) |> Seq.insert_at(10, 0) |> Seq.to_list()
    assert [1, 2, 3, 0] == Seq.new(1..3) |> Seq.insert_at(-1, 0) |> Seq.to_list()
    assert [1, 2, 0, 3] == Seq.new(1..3) |> Seq.insert_at(-2, 0) |> Seq.to_list()
    assert [0, 1, 2, 3] == Seq.new(1..3) |> Seq.insert_at(-10, 0) |> Seq.to_list()
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

  test "empty sequence operations" do
    empty = Seq.new()

    assert Seq.empty?(empty)
    assert 0 == Seq.count(empty)
    assert nil == Seq.first(empty)
    assert nil == Seq.last(empty)
    assert nil == Seq.at(empty, 0)
    assert :notfound == Seq.at(empty, 0, :notfound)
    assert [] == Seq.to_list(empty)
  end

  test "single element sequence operations" do
    seq = Seq.new([42])

    refute Seq.empty?(seq)
    assert 1 == Seq.count(seq)
    assert 42 == Seq.first(seq)
    assert 42 == Seq.last(seq)
    assert 42 == Seq.at(seq, 0)
    assert nil == Seq.at(seq, 1)
    assert Seq.empty?(Seq.rest(seq))
    assert Seq.empty?(Seq.butlast(seq))
  end

  test "at with sequences built via cons/conj" do
    # Build via cons (prepend)
    seq_cons = Seq.new() |> Seq.cons(3) |> Seq.cons(2) |> Seq.cons(1)
    assert 1 == Seq.at(seq_cons, 0)
    assert 2 == Seq.at(seq_cons, 1)
    assert 3 == Seq.at(seq_cons, 2)

    # Build via conj (append)
    seq_conj = Seq.new() |> Seq.conj(1) |> Seq.conj(2) |> Seq.conj(3)
    assert 1 == Seq.at(seq_conj, 0)
    assert 2 == Seq.at(seq_conj, 1)
    assert 3 == Seq.at(seq_conj, 2)
  end

  test "insert_at edge cases" do
    # Insert into empty sequence
    empty = Seq.new()
    assert [42] == Seq.insert_at(empty, 0, 42) |> Seq.to_list()
    assert [42] == Seq.insert_at(empty, 10, 42) |> Seq.to_list()

    # Insert into single element sequence
    single = Seq.new([1])
    assert [0, 1] == Seq.insert_at(single, 0, 0) |> Seq.to_list()
    assert [1, 2] == Seq.insert_at(single, 1, 2) |> Seq.to_list()
    assert [1, 2] == Seq.insert_at(single, 10, 2) |> Seq.to_list()
  end

  test "count remains correct after operations" do
    seq = Seq.new(1..5)
    assert 5 == Seq.count(seq)

    assert 6 == seq |> Seq.cons(0) |> Seq.count()
    assert 6 == seq |> Seq.conj(6) |> Seq.count()
    assert 4 == seq |> Seq.rest() |> Seq.count()
    assert 4 == seq |> Seq.butlast() |> Seq.count()
    assert 6 == seq |> Seq.insert_at(2, 99) |> Seq.count()
  end

  test "large sequence operations" do
    size = 1000
    seq = Seq.new(1..size)

    assert size == Seq.count(seq)
    assert 1 == Seq.first(seq)
    assert size == Seq.last(seq)

    # Test at various positions
    assert 1 == Seq.at(seq, 0)
    assert 500 == Seq.at(seq, 499)
    assert size == Seq.at(seq, size - 1)
    assert nil == Seq.at(seq, size)

    # Test insert_at at various positions
    assert 1001 == seq |> Seq.insert_at(0, 0) |> Seq.count()
    assert 1001 == seq |> Seq.insert_at(500, 0) |> Seq.count()
    assert 1001 == seq |> Seq.insert_at(size, 0) |> Seq.count()
  end

  test "at and to_list consistency" do
    seq = Seq.new(1..100)
    list = Seq.to_list(seq)

    for i <- 0..99 do
      assert Seq.at(seq, i) == Enum.at(list, i)
    end
  end
end
