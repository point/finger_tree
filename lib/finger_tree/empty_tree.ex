defmodule FingerTree.EmptyTree do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.SingleTree
  alias FingerTree.Protocols.Conjable
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Tree

  defstruct [:meter_object]

  @type t() :: %EmptyTree{meter_object: MeterObject.t()}

  @spec new(MeterObject.t()) :: t()
  def new(%MeterObject{} = meter_object) do
    %EmptyTree{meter_object: meter_object}
  end

  defimpl Conjable do
    def conj(%EmptyTree{meter_object: meter_object}, value) do
      SingleTree.new(meter_object, value)
    end

    def cons(%EmptyTree{meter_object: meter_object}, value) do
      SingleTree.new(meter_object, value)
    end
  end

  defimpl Measurable do
    def meter(%EmptyTree{meter_object: meter_object}), do: meter_object
    def measured(%EmptyTree{meter_object: %{id: id}}), do: id
  end

  defimpl Collectable do
    def into(%EmptyTree{} = tree) do
      collector_fun = fn
        tree_acc, {:cont, value} ->
          Conjable.conj(tree_acc, value)

        tree_acc, :done ->
          tree_acc

        _tree_acc, :halt ->
          :ok
      end

      initial_acc = tree

      {initial_acc, collector_fun}
    end
  end

  defimpl Tree do
    def first(_), do: nil
    def rest(_), do: nil
    def last(_), do: nil
    def butlast(_), do: nil
    def to_reverted_list(_), do: []
    def append(_, other), do: other
    def split(_, _, _), do: raise("You cannot split EmptyTree")
  end
end
