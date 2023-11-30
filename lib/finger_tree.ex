defmodule FingerTree do
  alias FingerTree.MeterObject
  alias FingerTree.EmptyTree
  alias FingerTree.SingleTree
  alias FingerTree.DeepTree
  alias FingerTree.Protocols.Tree
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Conjable

  @type t() :: EmptyTree.t() | SingleTree.t() | DeepTree.t()

  @spec finger_tree(MeterObject.t()) :: t()
  def finger_tree(%MeterObject{} = meter_obj), do: finger_tree(meter_obj, [])

  def finger_tree(%MeterObject{} = meter_obj, xs) when is_list(xs) do
    xs |> Enum.into(EmptyTree.new(meter_obj))
  end

  @spec to_list(t()) :: [term()]
  def to_list(tree), do: FingerTree.Impl.to_recursive_reverted_list(tree)

  @spec first(t()) :: term()
  def first(tree), do: Tree.first(tree)

  @spec rest(t()) :: t()
  def rest(tree), do: Tree.rest(tree)

  @spec last(t()) :: term()
  def last(tree), do: Tree.last(tree)

  @spec butlast(t()) :: t()
  def butlast(tree), do: Tree.butlast(tree)

  @spec measure(t) :: MeterObject.measure_result()
  def measure(tree), do: Measurable.measured(tree)

  @spec cons(t(), term()) :: t()
  def cons(tree, value), do: Conjable.cons(tree, value)

  @spec conj(t(), term()) :: t()
  def conj(tree, value), do: Conjable.conj(tree, value)

  @spec append(t(), t()) :: t()
  def append(tree, other), do: Tree.append(tree, other)

  @spec split(SingleTree.t() | DeepTree.t(), (MeterObject.measure_result() -> boolean())) ::
          {t(), term(), t()}
  def split(%{meter_object: %{id: id}} = tree, predicate), do: Tree.split(tree, predicate, id)
end
