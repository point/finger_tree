defmodule FingerTree.Digit2 do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.Protocols.Conjable
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Tree
  alias FingerTree.Digit
  import FingerTree.Impl

  defstruct [:meter_object, :a, :b, :cur_meter]

  @type t() :: %Digit2{
          meter_object: MeterObject.t(),
          a: term(),
          b: term(),
          cur_meter: MeterObject.measure_result()
        }

  @spec new(MeterObject.t(), term(), term()) :: t()
  def new(%MeterObject{opfn: opfn, measurefn: measurefn} = meter_object, a, b) do
    %Digit2{
      meter_object: meter_object,
      a: a,
      b: b,
      cur_meter:
        if(opfn, do: opfn.(maybe_measure(a) || measurefn.(a), maybe_measure(b) || measurefn.(b)))
    }
  end

  defimpl Measurable do
    def meter(%Digit2{meter_object: meter_object}), do: meter_object
    def measured(%Digit2{cur_meter: cur_meter}), do: cur_meter
  end

  defimpl Conjable do
    def conj(%Digit2{meter_object: meter_object, a: a, b: b}, value),
      do: Digit.new(meter_object, a, b, value)

    def cons(%Digit2{meter_object: meter_object, a: a, b: b}, value),
      do: Digit.new(meter_object, value, a, b)
  end

  defimpl Tree do
    def first(%Digit2{a: a}), do: a
    def rest(%Digit2{meter_object: meter_object, b: b}), do: Digit.new(meter_object, b)
    def last(%Digit2{b: b}), do: b
    def butlast(%Digit2{meter_object: meter_object, a: a}), do: Digit.new(meter_object, a)

    def to_reverted_list(%Digit2{a: a, b: b}),
      do: [maybe_reverted(b) || [b] | maybe_reverted(a) || [a]]

    def append(_, _), do: raise("You cannot append to Digit")

    def split(
          %Digit2{
            meter_object: %MeterObject{opfn: opfn, measurefn: measurefn} = meter_object,
            a: a,
            b: b
          },
          predicate,
          acc
        ) do
      acc = opfn.(acc, maybe_measure(a) || measurefn.(a))

      if predicate.(acc) do
        {nil, a, Digit.new(meter_object, b)}
      else
        {Digit.new(meter_object, a), b, nil}
      end
    end
  end
end
