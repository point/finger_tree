defmodule FingerTree.Digit4 do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.Digit
  alias FingerTree.Protocols.Conjable
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Tree
  import FingerTree.Impl

  defstruct [:meter_object, :a, :b, :c, :d, :cur_meter]

  @type t() :: %Digit4{
          meter_object: MeterObject.t(),
          a: term(),
          b: term(),
          c: term(),
          d: term(),
          cur_meter: MeterObject.measure_result()
        }

  @spec new(MeterObject.t(), term(), term(), term(), term()) :: t()
  def new(%MeterObject{opfn: opfn, measurefn: measurefn} = meter_object, a, b, c, d) do
    %Digit4{
      meter_object: meter_object,
      a: a,
      b: b,
      c: c,
      d: d,
      cur_meter:
        if(opfn,
          do:
            opfn.(
              opfn.(maybe_measure(a) || measurefn.(a), maybe_measure(b) || measurefn.(b)),
              opfn.(maybe_measure(c) || measurefn.(c), maybe_measure(d) || measurefn.(d))
            )
        )
    }
  end

  defimpl Measurable do
    def meter(%Digit4{meter_object: meter_object}), do: meter_object
    def measured(%Digit4{cur_meter: cur_meter}), do: cur_meter
  end

  defimpl Conjable do
    def conj(_, _), do: raise("You cannot conj to Digit4")
    def cons(_, _), do: raise("You cannot cons to Digit4")
  end

  defimpl Tree do
    def first(%Digit4{a: a}), do: a

    def rest(%Digit4{meter_object: meter_object, b: b, c: c, d: d}),
      do: Digit.new(meter_object, b, c, d)

    def last(%Digit4{d: d}), do: d

    def butlast(%Digit4{meter_object: meter_object, a: a, b: b, c: c}),
      do: Digit.new(meter_object, a, b, c)

    def to_reverted_list(%Digit4{a: a, b: b, c: c, d: d}),
      do: [
        maybe_reverted(d) || [d]
        | [maybe_reverted(c) || [c] | [maybe_reverted(b) || [b] | maybe_reverted(a) || [a]]]
      ]

    def append(_, _), do: raise("You cannot append to Digit")

    def split(
          %Digit4{
            meter_object: %MeterObject{opfn: opfn, measurefn: measurefn} = meter_object,
            a: a,
            b: b,
            c: c,
            d: d
          },
          predicate,
          acc
        ) do
      acc = opfn.(acc, maybe_measure(a) || measurefn.(a))

      if predicate.(acc) do
        {nil, a, Digit.new(meter_object, b, c, d)}
      else
        acc = opfn.(acc, maybe_measure(b) || measurefn.(b))

        if predicate.(acc) do
          {Digit.new(meter_object, a), b, Digit.new(meter_object, c, d)}
        else
          acc = opfn.(acc, maybe_measure(c) || measurefn.(c))

          if predicate.(acc) do
            {Digit.new(meter_object, a, b), c, Digit.new(meter_object, d)}
          else
            {Digit.new(meter_object, a, b, c), d, nil}
          end
        end
      end
    end
  end
end
