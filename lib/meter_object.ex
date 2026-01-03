defmodule FingerTree.MeterObject do
  alias __MODULE__
  alias FingerTree.Protocols.Measurable

  defstruct [:measurefn, :id, :opfn, :partial_sorterfn]

  @typep tree_element() :: term
  @typep measurefn() :: (tree_element -> measure_result) | nil
  @typep opfn() :: (measure_result(), measure_result() -> measure_result()) | nil

  @type measure_result() :: term
  @type t() :: %MeterObject{
          measurefn: measurefn(),
          id: measure_result(),
          opfn: opfn()
        }

  @spec new(measurefn(), measure_result(), opfn()) :: t()
  def new(measurefn, id, opfn, partial_sorterfn \\ &default_partial_sorterfn/2),
    do: %MeterObject{measurefn: measurefn, id: id, opfn: opfn, partial_sorterfn: partial_sorterfn}

  def finger_meter(nil),
    do: %MeterObject{measurefn: fn _ -> nil end, id: nil, opfn: fn _, _ -> nil end}

  def finger_meter(%MeterObject{id: id, opfn: opfn}) do
    %MeterObject{measurefn: fn t -> Measurable.measured(t) end, id: id, opfn: opfn}
  end

  def default_partial_sorterfn(_a, _b), do: true
end
