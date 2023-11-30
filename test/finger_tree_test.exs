defmodule FingerTreeTest do
  use ExUnit.Case, async: true

  alias FingerTree.MeterObject
  alias FingerTree.EmptyTree
  alias FingerTree.SingleTree
  alias FingerTree.DeepTree
  alias FingerTree.Digit1
  alias FingerTree.Digit2
  alias FingerTree.Digit3
  alias FingerTree.Digit4

  setup do
    {:ok, %{meter_object: MeterObject.new(fn _ -> 1 end, 0, &Kernel.+/2)}}
  end

  test "simple finger tree", %{meter_object: meter_object} do
    assert %EmptyTree{meter_object: ^meter_object} = FingerTree.finger_tree(meter_object, [])

    assert %SingleTree{meter_object: ^meter_object, value: 1} =
             FingerTree.finger_tree(meter_object, [1])

    assert %DeepTree{
             meter_object: ^meter_object,
             pre: %Digit1{a: 1},
             mid: %EmptyTree{},
             post: %Digit1{a: 2}
           } = FingerTree.finger_tree(meter_object, [1, 2])

    assert %DeepTree{pre: %Digit1{a: 1}, mid: %EmptyTree{}, post: %Digit2{a: 2, b: 3}} =
             FingerTree.finger_tree(meter_object, [1, 2, 3])

    assert %DeepTree{pre: %Digit1{a: 1}, mid: %EmptyTree{}, post: %Digit3{a: 2, b: 3, c: 4}} =
             FingerTree.finger_tree(meter_object, [1, 2, 3, 4])

    assert %DeepTree{pre: %Digit1{a: 1}, mid: %EmptyTree{}, post: %Digit4{a: 2, b: 3, c: 4, d: 5}} =
             FingerTree.finger_tree(meter_object, [1, 2, 3, 4, 5])

    assert %DeepTree{
             pre: %Digit1{a: 1},
             mid: %SingleTree{value: %Digit3{a: 2, b: 3, c: 4}},
             post: %Digit2{a: 5, b: 6}
           } =
             FingerTree.finger_tree(meter_object, [1, 2, 3, 4, 5, 6])

    assert %DeepTree{} = FingerTree.finger_tree(meter_object, Enum.to_list(1..100))
  end

  test "to_list", %{meter_object: meter_object} do
    assert Enum.to_list(1..100) ==
             FingerTree.finger_tree(meter_object, Enum.to_list(1..100)) |> FingerTree.to_list()
  end

  test "first + rest", %{meter_object: meter_object} do
    ft = FingerTree.finger_tree(meter_object, [1, 2, 3, 4, 5])

    assert %DeepTree{pre: %Digit1{a: 2}, mid: %EmptyTree{}, post: %Digit3{a: 3, b: 4, c: 5}} =
             FingerTree.rest(ft)

    assert %DeepTree{pre: %Digit1{a: 3}, mid: %EmptyTree{}, post: %Digit2{a: 4, b: 5}} =
             ft |> FingerTree.rest() |> FingerTree.rest()

    assert %DeepTree{pre: %Digit1{a: 4}, mid: %EmptyTree{}, post: %Digit1{a: 5}} =
             ft |> FingerTree.rest() |> FingerTree.rest() |> FingerTree.rest()

    assert %SingleTree{value: 5} =
             ft
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()

    assert %EmptyTree{} =
             ft
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()

    assert nil ==
             ft
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()
             |> FingerTree.rest()

    assert 1 = FingerTree.first(ft)
    assert 2 = FingerTree.first(ft |> FingerTree.rest())
    assert 3 = FingerTree.first(ft |> FingerTree.rest() |> FingerTree.rest())
    assert 4 = FingerTree.first(ft |> FingerTree.rest() |> FingerTree.rest() |> FingerTree.rest())

    assert 5 =
             FingerTree.first(
               ft
               |> FingerTree.rest()
               |> FingerTree.rest()
               |> FingerTree.rest()
               |> FingerTree.rest()
             )

    assert nil ==
             FingerTree.first(
               ft
               |> FingerTree.rest()
               |> FingerTree.rest()
               |> FingerTree.rest()
               |> FingerTree.rest()
               |> FingerTree.rest()
             )

    assert 1 = FingerTree.finger_tree(meter_object, Enum.to_list(1..100)) |> FingerTree.first()
  end

  test "extended rest", %{meter_object: meter_object} do
    from = 1
    to = 2048
    r = from..to
    ft = FingerTree.finger_tree(meter_object, Enum.to_list(r))

    Enum.reduce(Enum.drop(r, 1), ft, fn new_from, ft ->
      ft2 = FingerTree.rest(ft)

      assert Enum.to_list(new_from..to) == FingerTree.to_list(ft2)
      ft2
    end)

    assert FingerTree.measure(ft) == 2048
  end

  test "last + butlast", %{meter_object: meter_object} do
    ft = FingerTree.finger_tree(meter_object, [1, 2, 3, 4, 5])
    assert 5 = FingerTree.last(ft)

    assert %DeepTree{pre: %Digit1{a: 1}, mid: %EmptyTree{}, post: %Digit3{a: 2, b: 3, c: 4}} =
             FingerTree.butlast(ft)

    assert %DeepTree{pre: %Digit1{a: 1}, mid: %EmptyTree{}, post: %Digit2{a: 2, b: 3}} =
             FingerTree.butlast(ft) |> FingerTree.butlast()

    assert %SingleTree{value: 1} =
             FingerTree.butlast(ft)
             |> FingerTree.butlast()
             |> FingerTree.butlast()
             |> FingerTree.butlast()

    assert %EmptyTree{} =
             FingerTree.butlast(ft)
             |> FingerTree.butlast()
             |> FingerTree.butlast()
             |> FingerTree.butlast()
             |> FingerTree.butlast()
  end

  test "extended butlast", %{meter_object: meter_object} do
    from = 1
    to = 2048
    r = from..to
    ft = FingerTree.finger_tree(meter_object, Enum.to_list(r))

    Enum.reduce(Enum.drop(Enum.reverse(r), 1), ft, fn new_to, ft ->
      ft2 = FingerTree.butlast(ft)

      assert Enum.to_list(from..new_to) == FingerTree.to_list(ft2)
      ft2
    end)

    assert FingerTree.measure(ft) == 2048
  end

  test "cons/conj", %{meter_object: meter_object} do
    r = 1..100

    assert Enum.to_list(Enum.reverse(r)) ==
             r
             |> Enum.reduce(
               FingerTree.finger_tree(meter_object),
               fn x, ft ->
                 FingerTree.cons(ft, x)
               end
             )
             |> FingerTree.to_list()

    assert Enum.to_list(r) ==
             r
             |> Enum.reduce(
               FingerTree.finger_tree(meter_object),
               fn x, ft ->
                 FingerTree.conj(ft, x)
               end
             )
             |> FingerTree.to_list()
  end

  test "append", %{meter_object: meter_object} do
    ft1 = FingerTree.finger_tree(meter_object, Enum.to_list(1..1024))
    ft2 = FingerTree.finger_tree(meter_object, Enum.to_list(1025..2048))

    assert Enum.to_list(1..2048) == FingerTree.append(ft1, ft2) |> FingerTree.to_list()
  end

  test "split", %{meter_object: meter_object} do
    ft = FingerTree.finger_tree(meter_object, [1, 2, 3])

    assert {%FingerTree.SingleTree{
              value: 1
            }, 2,
            %FingerTree.SingleTree{
              value: 3
            }} = FingerTree.split(ft, fn m -> m == 2 end)

    ft = FingerTree.finger_tree(meter_object, [1])
    assert {%EmptyTree{}, _, %EmptyTree{}} = FingerTree.split(ft, fn m -> m >= 1024 end)

    ft = FingerTree.finger_tree(meter_object, Enum.to_list(1..2048))

    l1 = FingerTree.finger_tree(meter_object, Enum.to_list(1..1023)) |> FingerTree.to_list()
    l2 = FingerTree.finger_tree(meter_object, Enum.to_list(1025..2048)) |> FingerTree.to_list()

    assert {ft1, 1024, ft2} = FingerTree.split(ft, fn m -> m >= 1024 end)
    assert FingerTree.to_list(ft1) == l1
    assert FingerTree.to_list(ft2) == l2
  end
end
