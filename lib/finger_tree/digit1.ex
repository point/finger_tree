defmodule FingerTree.Digit1 do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.Protocols.Tree
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Conjable
  alias FingerTree.Digit
  import FingerTree.Impl

  defstruct [:meter_object, :a, :cur_meter]

  @type t() :: %Digit1{
          meter_object: MeterObject.t(),
          a: term(),
          cur_meter: MeterObject.measure_result()
        }

  @spec new(MeterObject.t(), term()) :: t()
  def new(%MeterObject{opfn: opfn, measurefn: measurefn} = meter_object, a) do
    %Digit1{
      meter_object: meter_object,
      a: a,
      cur_meter: if(opfn, do: maybe_measure(a) || measurefn.(a))
    }
  end

  defimpl Measurable do
    def meter(%Digit1{meter_object: meter_object}), do: meter_object
    def measured(%Digit1{cur_meter: cur_meter}), do: cur_meter
  end

  defimpl Conjable do
    def conj(%Digit1{meter_object: meter_object, a: a}, value),
      do: Digit.new(meter_object, a, value)

    def cons(%Digit1{meter_object: meter_object, a: a}, value),
      do: Digit.new(meter_object, value, a)
  end

  defimpl Tree do
    def first(%Digit1{a: a}), do: a
    def rest(%Digit1{} = _), do: nil
    def last(%Digit1{a: a}), do: a
    def butlast(%Digit1{} = _), do: nil
    def to_recursive_reverted_list(%Digit1{a: a}), do: maybe_reverted(a) || [a]
    def append(_, _), do: raise("You cannot append to Digit")
    def split(%Digit1{a: a}, _, _), do: {nil, a, nil}
    def to_list(%Digit1{a: a}), do: [a]
  end
end
