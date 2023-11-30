defmodule FingerTree.SingleTree do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.EmptyTree
  alias FingerTree.Digit
  alias FingerTree.Protocols.Conjable
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Tree

  import FingerTree.Impl

  defstruct [:meter_object, :value]

  @type t() :: %SingleTree{meter_object: MeterObject.t(), value: term()}

  @spec new(MeterObject.t(), term()) :: t()
  def new(%MeterObject{} = meter_object, value),
    do: %SingleTree{meter_object: meter_object, value: value}

  defimpl Conjable do
    def conj(%SingleTree{meter_object: meter_object, value: tree_value}, value) do
      deep(
        Digit.new(meter_object, tree_value),
        # EmptyTree.new(MeterObject.finger_meter(meter_object)),
        EmptyTree.new(meter_object),
        Digit.new(meter_object, value)
      )
    end

    def cons(%SingleTree{meter_object: meter_object, value: tree_value}, value) do
      deep(
        Digit.new(meter_object, value),
        EmptyTree.new(meter_object),
        Digit.new(meter_object, tree_value)
      )
    end
  end

  defimpl Measurable do
    def meter(%SingleTree{meter_object: meter_object}), do: meter_object

    def measured(%SingleTree{meter_object: %{measurefn: measurefn}, value: value}),
      do: maybe_measure(value) || measurefn.(value)
  end

  defimpl Tree do
    def first(%SingleTree{value: value}), do: value
    def rest(%SingleTree{meter_object: meter_object}), do: EmptyTree.new(meter_object)
    def last(%SingleTree{value: value}), do: value
    def butlast(%SingleTree{meter_object: meter_object}), do: EmptyTree.new(meter_object)

    def to_recursive_reverted_list(%SingleTree{value: value}),
      do: maybe_reverted(value) || [value]

    def append(%SingleTree{value: value}, other), do: Conjable.cons(other, value)

    def split(%SingleTree{meter_object: meter_object, value: value}, _, _),
      do: {EmptyTree.new(meter_object), value, EmptyTree.new(meter_object)}

    def to_list(%SingleTree{value: value}), do: [value]
  end
end
