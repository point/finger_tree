defmodule FingerTree.Digit3 do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.Protocols.Conjable
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Tree
  alias FingerTree.Digit
  import FingerTree.Impl

  defstruct [:meter_object, :a, :b, :c, :cur_meter]

  @type t() :: %Digit3{
          meter_object: MeterObject.t(),
          a: term(),
          b: term(),
          c: term(),
          cur_meter: MeterObject.measure_result()
        }

  @spec new(MeterObject.t(), term(), term(), term()) :: t()
  def new(%MeterObject{opfn: opfn, measurefn: measurefn} = meter_object, a, b, c) do
    %Digit3{
      meter_object: meter_object,
      a: a,
      b: b,
      c: c,
      cur_meter:
        if(opfn,
          do:
            opfn.(
              opfn.(maybe_measure(a) || measurefn.(a), maybe_measure(b) || measurefn.(b)),
              maybe_measure(c) || measurefn.(c)
            )
        )
    }
  end

  defimpl Measurable do
    def meter(%Digit3{meter_object: meter_object}), do: meter_object
    def measured(%Digit3{cur_meter: cur_meter}), do: cur_meter
  end

  defimpl Conjable do
    def conj(%Digit3{meter_object: meter_object, a: a, b: b, c: c}, value),
      do: Digit.new(meter_object, a, b, c, value)

    def cons(%Digit3{meter_object: meter_object, a: a, b: b, c: c}, value),
      do: Digit.new(meter_object, value, a, b, c)
  end

  defimpl Tree do
    def first(%Digit3{a: a}), do: a
    def rest(%Digit3{meter_object: meter_object, b: b, c: c}), do: Digit.new(meter_object, b, c)
    def last(%Digit3{c: c}), do: c

    def butlast(%Digit3{meter_object: meter_object, a: a, b: b}),
      do: Digit.new(meter_object, a, b)

    def to_reverted_list(%Digit3{a: a, b: b, c: c}),
      do: [maybe_reverted(c) || [c] | [maybe_reverted(b) || [b] | maybe_reverted(a) || [a]]]

    def append(_, _), do: raise("You cannot append to Digit")

    def split(
          %Digit3{
            meter_object: %MeterObject{opfn: opfn, measurefn: measurefn} = meter_object,
            a: a,
            b: b,
            c: c
          },
          predicate,
          acc
        ) do
      acc = opfn.(acc, maybe_measure(a) || measurefn.(a))

      if predicate.(acc) do
        {nil, a, Digit.new(meter_object, b, c)}
      else
        acc = opfn.(acc, maybe_measure(b) || measurefn.(b))

        if predicate.(acc) do
          {Digit.new(meter_object, a), b, Digit.new(meter_object, c)}
        else
          {Digit.new(meter_object, a, b), c, nil}
        end
      end
    end
  end
end
