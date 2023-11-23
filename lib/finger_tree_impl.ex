defmodule FingerTree.Impl do
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Tree
  alias FingerTree.MeterObject
  alias FingerTree.DeepTree

  alias FingerTree.Protocols.Measurable

  @spec deep(FingerTree.Digit.t(), FingerTree.t(), FingerTree.Digit.t()) :: DeepTree.t()
  def deep(pre, m, post) do
    %{opfn: opfn} = meter_object = Measurable.meter(pre)

    DeepTree.new(
      meter_object,
      pre,
      m,
      post,
      if(opfn, do: fn -> measured3(meter_object, pre, m, post) end)
    )
  end

  @spec measured3(MeterObject.t(), FingerTree.Digit.t(), FingerTree.t(), FingerTree.Digit.t()) ::
          MeterObject.measure_result()
  def measured3(%MeterObject{opfn: nil}, _pre, _m, _post), do: nil

  def measured3(%MeterObject{opfn: opfn}, pre, m, post),
    do:
      opfn.(
        opfn.(Measurable.measured(pre), Measurable.measured(m)),
        Measurable.measured(post)
      )

  @spec maybe_measure(FingerTree.t() | FingerTree.Digit.t() | term) ::
          MeterObject.measure_result() | nil
  def maybe_measure(o) do
    Measurable.impl_for(o) && Measurable.measured(o)
  end

  @spec maybe_reverted(FingerTree.t() | FingerTree.Digit.t() | term) :: [term()] | nil
  def maybe_reverted(o) do
    Tree.impl_for(o) && Tree.to_reverted_list(o)
  end

  @spec to_list(FingerTree.t() | nil) :: [term()]
  def to_list(nil), do: nil
  def to_list(tree), do: Tree.to_reverted_list(tree) |> revert()

  @spec revert([] | [term()]) :: [term()]
  def revert(nested_list), do: revert(nested_list, [])
  def revert([t | rest], acc) when is_list(t), do: revert(rest, revert(t, acc))
  def revert([t | rest], acc), do: revert(rest, [t | acc])
  def revert([], acc), do: acc

  @spec to_tree(MeterObject.t(), [term] | nil) :: FingerTree.t()
  def to_tree(meter_object, nil), do: FingerTree.EmptyTree.new(meter_object)

  def to_tree(meter_object, xs) when is_list(xs),
    do: xs |> Enum.into(FingerTree.EmptyTree.new(meter_object))
end
