defmodule FingerTree.Seq do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.EmptyTree
  alias FingerTree.Protocols.Conjable

  defstruct [:ft]

  @type t() :: %Seq{ft: FingerTree.t()}

  def new(), do: %Seq{ft: FingerTree.finger_tree(meter_object())}
  def new(%Range{} = r), do: r |> Enum.to_list() |> new()
  def new(xs) when is_list(xs), do: %Seq{ft: FingerTree.finger_tree(meter_object(), xs)}
  def to_list(%Seq{ft: tree}), do: FingerTree.to_list(tree)

  @spec first(t()) :: term()
  def first(%Seq{ft: tree}), do: FingerTree.first(tree)

  @spec rest(t()) :: t()
  def rest(%Seq{ft: tree}), do: %Seq{ft: FingerTree.rest(tree)}

  @spec last(t()) :: term()
  def last(%Seq{ft: tree}), do: FingerTree.last(tree)

  @spec butlast(t()) :: t()
  def butlast(%Seq{ft: tree}), do: %Seq{ft: FingerTree.butlast(tree)}

  @spec cons(t(), term()) :: t()
  def cons(%Seq{ft: tree}, value), do: %Seq{ft: FingerTree.cons(tree, value)}

  @spec conj(t(), term()) :: t()
  def conj(%Seq{ft: tree}, value), do: %Seq{ft: FingerTree.conj(tree, value)}

  @spec append(t(), t()) :: t()
  def append(%Seq{ft: tree}, %Seq{ft: other}), do: %Seq{ft: FingerTree.append(tree, other)}

  @spec split(t(), (MeterObject.measure_result() -> boolean())) ::
          {t(), term(), t()}
  def split(%Seq{ft: tree}, predicate) do
    {l, v, r} = FingerTree.split(tree, predicate)
    {%Seq{ft: l}, v, %Seq{ft: r}}
  end

  @spec take(t(), integer()) :: t()
  def take(_, 0), do: %Seq{ft: EmptyTree.new(meter_object())}

  def take(%Seq{ft: tree} = seq, n) when n < 0 do
    n = count(seq) + n
    {_, v, r} = FingerTree.split(tree, fn pos -> pos >= n end)

    if n <= 0,
      do: %Seq{ft: FingerTree.cons(r, v)},
      else: %Seq{ft: r}
  end

  def take(%Seq{ft: tree}, n) do
    {l, v, _} = FingerTree.split(tree, fn pos -> pos >= n end)
    %Seq{ft: FingerTree.conj(l, v)}
  end

  @spec drop(t(), integer()) :: t()
  def drop(%Seq{} = seq, 0), do: seq

  def drop(%Seq{ft: tree} = seq, n) when n < 0 do
    n = count(seq) + n
    {l, v, _r} = FingerTree.split(tree, fn pos -> pos >= n end)

    if n <= 0, do: %Seq{ft: l}, else: %Seq{ft: FingerTree.conj(l, v)}
  end

  def drop(%Seq{ft: tree}, n) do
    {_, _, r} = FingerTree.split(tree, fn pos -> pos >= n end)
    %Seq{ft: r}
  end

  @spec count(t()) :: non_neg_integer()
  def count(%Seq{ft: tree}), do: FingerTree.measure(tree)

  @spec at(t(), non_neg_integer()) :: term()
  def at(%Seq{} = seq, n, notfound \\ nil) when n >= 0 do
    cond do
      n > Seq.count(seq) - 1 -> notfound
      :otherwise -> drop(seq, n) |> first()
    end
  end

  @spec empty?(t()) :: boolean()
  def empty?(%Seq{ft: tree}), do: FingerTree.empty?(tree)

  defimpl Collectable do
    def into(%Seq{} = seq) do
      collector_fun = fn
        %Seq{ft: acc_ft} = acc, {:cont, value} ->
          %{acc | ft: Conjable.conj(acc_ft, value)}

        acc, :done ->
          acc

        _acc, :halt ->
          :ok
      end

      initial_acc = seq

      {initial_acc, collector_fun}
    end
  end

  defimpl Enumerable do
    def count(%Seq{} = seq) do
      {:ok, Seq.count(seq)}
    end

    def member?(_seq, _element) do
      {:error, __MODULE__}
    end

    def reduce(seq, acc, fun)

    def reduce(%Seq{} = seq, {:cont, acc}, fun) do
      case Seq.first(seq) do
        nil -> {:done, acc}
        element -> reduce(Seq.rest(seq), fun.(element, acc), fun)
      end
    end

    def reduce(_seq, {:halt, acc}, _fun) do
      {:halted, acc}
    end

    def reduce(seq, {:suspend, acc}, fun) do
      {:suspended, acc, &reduce(seq, &1, fun)}
    end

    def slice(seq) do
      {:ok, Seq.count(seq),
       fn start, len ->
         seq
         |> Seq.drop(start)
         |> Seq.take(len)
         |> Seq.to_list()
       end}
    end
  end

  defp meter_object(), do: MeterObject.new(fn _ -> 1 end, 0, &Kernel.+/2)
end
