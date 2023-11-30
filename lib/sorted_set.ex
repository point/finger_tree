defmodule FingerTree.SortedSet do
  alias __MODULE__
  alias FingerTree.EmptyTree
  alias FingerTree.MeterObject

  defstruct [:ft, :comparator]
  @type t() :: %SortedSet{ft: FingerTree.t()}

  defmodule LOMeter do
    @enforce_keys [:len, :obj]
    defstruct([:len, :obj])
  end

  def new(comparator) when is_function(comparator, 2),
    do: %SortedSet{ft: FingerTree.finger_tree(meter_object()), comparator: comparator}

  def new(comparator, xs) when is_function(comparator, 2),
    do: %SortedSet{ft: FingerTree.finger_tree(meter_object(), xs), comparator: comparator}

  def to_list(%SortedSet{ft: tree}), do: FingerTree.to_list(tree)

  @spec first(t()) :: term()
  def first(%SortedSet{ft: tree}), do: FingerTree.first(tree)

  @spec rest(t()) :: t()
  def rest(%SortedSet{ft: tree}), do: %SortedSet{ft: FingerTree.rest(tree)}

  @spec last(t()) :: term()
  def last(%SortedSet{ft: tree}), do: FingerTree.last(tree)

  @spec butlast(t()) :: t()
  def butlast(%SortedSet{ft: tree}), do: %SortedSet{ft: FingerTree.butlast(tree)}

  def put(%SortedSet{ft: %EmptyTree{} = tree} = ss, value) do
    %SortedSet{ss | ft: FingerTree.cons(tree, value)}
  end

  defdelegate cons(ss, value), to: __MODULE__, as: :put
  defdelegate conj(ss, value), to: __MODULE__, as: :put

  def put(%SortedSet{ft: tree, comparator: comparator} = ss, value) do
    {l, x, r} =
      FingerTree.split(tree, fn %LOMeter{obj: o} ->
        comparator.(value, o) in [:lt, :eq]
      end)

    case comparator.(value, x) do
      # already in the set
      :eq ->
        ss

      :gt ->
        %SortedSet{ss | ft: FingerTree.append(FingerTree.conj(l, x), FingerTree.cons(r, value))}

      :lt ->
        %SortedSet{ss | ft: FingerTree.append(FingerTree.conj(l, value), FingerTree.cons(r, x))}
    end
  end

  defimpl Collectable do
    def into(%SortedSet{} = ss) do
      collector_fun = fn
        %SortedSet{} = acc, {:cont, value} ->
          SortedSet.put(acc, value)

        acc, :done ->
          acc

        _acc, :halt ->
          :ok
      end

      initial_acc = ss

      {initial_acc, collector_fun}
    end
  end

  defp meter_object(),
    do:
      MeterObject.new(
        fn o -> %LOMeter{len: 1, obj: o} end,
        %LOMeter{len: 0, obj: nil},
        fn %LOMeter{len: len1, obj: o1}, %LOMeter{len: len2, obj: o2} ->
          %LOMeter{len: len1 + len2, obj: o2 || o1}
        end
      )
end
