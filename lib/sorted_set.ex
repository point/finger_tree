defmodule FingerTree.SortedSet do
  alias __MODULE__
  alias FingerTree.EmptyTree
  alias FingerTree.MeterObject

  defstruct [:ft, :comparator]
  @typep comparator() :: (term(), term() -> :lt | :gt | :eq)
  @type t() :: %SortedSet{ft: FingerTree.t(), comparator: comparator}

  defmodule LOMeter do
    @type t() :: %LOMeter{len: integer(), obj: term()}
    @enforce_keys [:len, :obj]
    defstruct([:len, :obj])
  end

  @spec new([term()], comparator()) :: t()
  def new(
        xs \\ [],
        comparator \\ fn o1, o2 ->
          cond do
            o1 == o2 -> :eq
            o1 < o2 -> :lt
            :otherwise -> :gt
          end
        end
      )

  def new(%Range{} = r, comparator), do: new(Enum.to_list(r), comparator)

  def new(xs, comparator) when is_list(xs) do
    xs
    |> Enum.into(%SortedSet{ft: FingerTree.finger_tree(meter_object()), comparator: comparator})
  end

  @spec to_list(t()) :: [term()]
  def to_list(%SortedSet{ft: tree}), do: FingerTree.to_list(tree)

  @spec first(t()) :: term()
  def first(%SortedSet{ft: tree}), do: FingerTree.first(tree)

  @spec rest(t()) :: t()
  def rest(%SortedSet{ft: tree} = ss), do: %SortedSet{ss | ft: FingerTree.rest(tree)}

  @spec last(t()) :: term()
  def last(%SortedSet{ft: tree}), do: FingerTree.last(tree)

  @spec butlast(t()) :: t()
  def butlast(%SortedSet{ft: tree} = ss), do: %SortedSet{ss | ft: FingerTree.butlast(tree)}

  @spec put(t(), term()) :: t()
  def put(%SortedSet{ft: %EmptyTree{} = tree} = ss, value) do
    %SortedSet{ss | ft: FingerTree.cons(tree, value)}
  end

  def put(%SortedSet{ft: tree, comparator: comparator} = ss, value) do
    cond do
      comparator.(value, FingerTree.last(tree)) == :gt ->
        %SortedSet{ss | ft: FingerTree.conj(tree, value)}

      comparator.(value, FingerTree.first(tree)) == :lt ->
        %SortedSet{ss | ft: FingerTree.cons(tree, value)}

      :otherwise ->
        {l, x, r} =
          FingerTree.split(tree, fn %LOMeter{obj: o} ->
            comparator.(value, o) in [:lt, :eq]
          end)

        case comparator.(value, x) do
          # already in the set
          :eq ->
            ss

          :gt ->
            %SortedSet{
              ss
              | ft: FingerTree.append(FingerTree.conj(l, x), FingerTree.cons(r, value))
            }

          :lt ->
            %SortedSet{
              ss
              | ft: FingerTree.append(FingerTree.conj(l, value), FingerTree.cons(r, x))
            }
        end
    end
  end

  defdelegate cons(ss, value), to: __MODULE__, as: :put
  defdelegate conj(ss, value), to: __MODULE__, as: :put

  @spec count(t()) :: non_neg_integer()
  def count(%SortedSet{ft: tree}) do
    %LOMeter{len: count} = FingerTree.measure(tree)
    count
  end

  @spec empty?(t()) :: boolean()
  def empty?(%SortedSet{ft: tree}), do: FingerTree.empty?(tree)

  @spec member?(t(), term()) :: boolean()
  def member?(%SortedSet{ft: tree, comparator: comparator}, value) do
    {_l, x, _r} =
      FingerTree.split(tree, fn %LOMeter{obj: o} ->
        comparator.(value, o) in [:lt, :eq]
      end)

    x == value
  end

  @spec reject(t(), term()) :: t()
  def reject(%SortedSet{ft: tree, comparator: comparator} = ss, value) do
    {l, x, r} =
      FingerTree.split(tree, fn %LOMeter{obj: o} ->
        comparator.(value, o) in [:lt, :eq]
      end)

    if x == value do
      %SortedSet{ss | ft: FingerTree.append(l, r)}
    else
      %SortedSet{ss | ft: FingerTree.append(FingerTree.conj(l, x), r)}
    end
  end

  @spec split(t(), (term() -> boolean())) :: {t(), term() | nil, t()}
  def split(%SortedSet{ft: tree} = ss, fun) when is_function(fun) do
    {l, x, r} =
      FingerTree.split(tree, fn %LOMeter{obj: o} -> fun.(o) end)

    {%SortedSet{ss | ft: l}, x, %SortedSet{ss | ft: r}}
  end

  @spec split_at(t(), non_neg_integer(), term()) :: {t(), term(), t()}
  def split_at(ss, pos, notfound \\ nil)

  def split_at(%SortedSet{ft: %{meter_object: meter_object}} = ss, pos, notfound)
      when pos < 0,
      do: {%SortedSet{ss | ft: EmptyTree.new(meter_object)}, notfound, ss}

  def split_at(%SortedSet{ft: %{meter_object: meter_object} = tree} = ss, pos, notfound) do
    count = count(ss)

    cond do
      pos < count ->
        {l, x, r} = FingerTree.split(tree, fn %LOMeter{len: l} -> l > pos end)
        {%SortedSet{ss | ft: l}, x, %SortedSet{ss | ft: r}}

      :otherwise ->
        {ss, notfound, %SortedSet{ss | ft: EmptyTree.new(meter_object)}}
    end
  end

  @spec at(t(), non_neg_integer(), term()) :: term()
  def at(%SortedSet{} = ss, pos, notfound \\ nil) do
    {_, x, _} = split_at(ss, pos, notfound)
    x
  end

  @spec append(t(), t()) :: t()
  def append(%SortedSet{} = ss1, %SortedSet{} = ss2) do
    ss2 |> to_list() |> Enum.into(ss1)
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

  defimpl Enumerable do
    def count(%SortedSet{} = ss) do
      {:ok, SortedSet.count(ss)}
    end

    def member?(_seq, _element) do
      {:error, __MODULE__}
    end

    def reduce(seq, acc, fun)

    def reduce(%SortedSet{} = ss, {:cont, acc}, fun) do
      case SortedSet.first(ss) do
        nil -> {:done, acc}
        element -> reduce(SortedSet.rest(ss), fun.(element, acc), fun)
      end
    end

    def reduce(_seq, {:halt, acc}, _fun) do
      {:halted, acc}
    end

    def reduce(seq, {:suspend, acc}, fun) do
      {:suspended, acc, &reduce(seq, &1, fun)}
    end

    def slice(_) do
      {:error, __MODULE__}
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
