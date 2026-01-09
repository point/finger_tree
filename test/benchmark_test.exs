defmodule BenchmarkTest do
  use ExUnit.Case, async: false

  alias FingerTree.Seq

  @moduletag :benchmark
  @moduletag timeout: :infinity

  @small_size 1_000
  @medium_size 10_000
  @large_size 100_000

  describe "prepend (cons) operations" do
    test "benchmark prepend (small)" do
      Benchee.run(
        %{
          "List prepend (small)" => fn ->
            Enum.reduce(1..@small_size, [], fn x, acc -> [x | acc] end)
          end,
          "Seq cons (small)" => fn ->
            Enum.reduce(1..@small_size, Seq.new(), fn x, acc -> Seq.cons(acc, x) end)
          end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end

    test "benchmark prepend (medium)" do
      Benchee.run(
        %{
          "List prepend (medium)" => fn ->
            Enum.reduce(1..@medium_size, [], fn x, acc -> [x | acc] end)
          end,
          "Seq cons (medium)" => fn ->
            Enum.reduce(1..@medium_size, Seq.new(), fn x, acc -> Seq.cons(acc, x) end)
          end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end

    test "benchmark prepend (large)" do
      Benchee.run(
        %{
          "List prepend (large)" => fn ->
            Enum.reduce(1..@large_size, [], fn x, acc -> [x | acc] end)
          end,
          "Seq cons (large)" => fn ->
            Enum.reduce(1..@large_size, Seq.new(), fn x, acc -> Seq.cons(acc, x) end)
          end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end
  end

  describe "append (conj) operations" do
    test "benchmark append (small)" do
      Benchee.run(
        %{
          "List append (small)" => fn ->
            Enum.reduce(1..@small_size, [], fn x, acc -> acc ++ [x] end)
          end,
          "Seq conj (small)" => fn ->
            Enum.reduce(1..@small_size, Seq.new(), fn x, acc -> Seq.conj(acc, x) end)
          end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end

    test "benchmark append (medium)" do
      Benchee.run(
        %{
          "List append (medium)" => fn ->
            Enum.reduce(1..@medium_size, [], fn x, acc -> acc ++ [x] end)
          end,
          "Seq conj (medium)" => fn ->
            Enum.reduce(1..@medium_size, Seq.new(), fn x, acc -> Seq.conj(acc, x) end)
          end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end
  end

  describe "random access operations" do
    test "benchmark random access at middle (small)" do
      list = Enum.to_list(1..@small_size)
      seq = Seq.new(1..@small_size)

      Benchee.run(
        %{
          "List Enum.at (small)" => fn -> Enum.at(list, div(@small_size, 2)) end,
          "Seq.at (small)" => fn -> Seq.at(seq, div(@small_size, 2)) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end

    test "benchmark random access at middle (medium)" do
      list = Enum.to_list(1..@medium_size)
      seq = Seq.new(1..@medium_size)

      Benchee.run(
        %{
          "List Enum.at (medium)" => fn -> Enum.at(list, div(@medium_size, 2)) end,
          "Seq.at (medium)" => fn -> Seq.at(seq, div(@medium_size, 2)) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end

    test "benchmark random access at middle (large)" do
      list = Enum.to_list(1..@large_size)
      seq = Seq.new(1..@large_size)

      Benchee.run(
        %{
          "List Enum.at (large)" => fn -> Enum.at(list, div(@large_size, 2)) end,
          "Seq.at (large)" => fn -> Seq.at(seq, div(@large_size, 2)) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end
  end

  describe "head/first and tail/rest operations" do
    test "benchmark first element access (large)" do
      list = Enum.to_list(1..@large_size)
      seq = Seq.new(1..@large_size)

      Benchee.run(
        %{
          "List hd (large)" => fn -> hd(list) end,
          "Seq.first (large)" => fn -> Seq.first(seq) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end

    test "benchmark tail/rest (large)" do
      list = Enum.to_list(1..@large_size)
      seq = Seq.new(1..@large_size)

      Benchee.run(
        %{
          "List tl (large)" => fn -> tl(list) end,
          "Seq.rest (large)" => fn -> Seq.rest(seq) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end
  end

  describe "last element operations" do
    test "benchmark last element access (large)" do
      list = Enum.to_list(1..@large_size)
      seq = Seq.new(1..@large_size)

      Benchee.run(
        %{
          "List List.last (large)" => fn -> List.last(list) end,
          "Seq.last (large)" => fn -> Seq.last(seq) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end
  end

  describe "concatenation operations" do
    test "benchmark concatenation (small)" do
      list = Enum.to_list(1..@small_size)
      seq = Seq.new(1..@small_size)

      Benchee.run(
        %{
          "List ++ (small)" => fn -> list ++ list end,
          "Seq.append (small)" => fn -> Seq.append(seq, seq) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end

    test "benchmark concatenation (medium)" do
      list = Enum.to_list(1..@medium_size)
      seq = Seq.new(1..@medium_size)

      Benchee.run(
        %{
          "List ++ (medium)" => fn -> list ++ list end,
          "Seq.append (medium)" => fn -> Seq.append(seq, seq) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end
  end

  describe "count operations" do
    test "benchmark count (large)" do
      list = Enum.to_list(1..@large_size)
      seq = Seq.new(1..@large_size)

      Benchee.run(
        %{
          "List length (large)" => fn -> length(list) end,
          "Seq.count (large)" => fn -> Seq.count(seq) end
        },
        time: 2,
        memory_time: 1,
        print: [configuration: false]
      )
    end
  end
end
