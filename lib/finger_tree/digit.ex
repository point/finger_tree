defmodule FingerTree.Digit do
  alias FingerTree.MeterObject
  alias FingerTree.Digit1
  alias FingerTree.Digit2
  alias FingerTree.Digit3
  alias FingerTree.Digit4

  @type t() :: Digit1.t() | Digit2.t() | Digit3.t() | Digit4.t()

  def new(%MeterObject{} = meter_object, values) when is_list(values),
    do: apply(__MODULE__, :digit, [meter_object | Enum.filter(values, &Function.identity/1)])

  def new(%MeterObject{} = meter_object, a), do: Digit1.new(meter_object, a)
  def new(%MeterObject{} = meter_object, a, b), do: Digit2.new(meter_object, a, b)
  def new(%MeterObject{} = meter_object, a, b, c), do: Digit3.new(meter_object, a, b, c)
  def new(%MeterObject{} = meter_object, a, b, c, d), do: Digit4.new(meter_object, a, b, c, d)
end
