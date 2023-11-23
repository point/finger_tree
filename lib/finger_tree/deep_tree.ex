defmodule FingerTree.DeepTree do
  alias __MODULE__
  alias FingerTree.MeterObject
  alias FingerTree.Digit
  alias FingerTree.Digit1
  alias FingerTree.Digit4
  alias FingerTree.EmptyTree
  alias FingerTree.SingleTree
  alias FingerTree.Protocols.Conjable
  alias FingerTree.Protocols.Measurable
  alias FingerTree.Protocols.Tree

  import FingerTree.Impl

  defstruct [:meter_object, :pre, :mid, :post, :meterfn]

  @type t() :: %DeepTree{
          meter_object: MeterObject.t(),
          pre: Digit.t(),
          mid: SingleTree.t() | EmptyTree.t(),
          post: Digit.t(),
          meterfn: (-> MeterObject.measure_result())
        }

  @spec new(
          MeterObject.t(),
          Digit.t(),
          EmptyTree.t() | SingleTree.t(),
          Digit.t(),
          (-> MeterObject.measure_result())
        ) :: t()
  def new(%MeterObject{} = meter_object, pre, mid, post, meterfn),
    do: %DeepTree{
      meter_object: meter_object,
      pre: pre,
      mid: mid,
      post: post,
      meterfn: meterfn
    }

  @spec left(Digit.t(), EmptyTree.t() | SingleTree.t(), Digit.t()) :: t()
  def left(%{a: _} = pre, mid, post) do
    deep(pre, mid, post)
  end

  def left(
        _pre,
        %EmptyTree{},
        %Digit1{a: a, meter_object: meter_object}
      ) do
    SingleTree.new(meter_object, a)
  end

  @spec left(Digit.t() | nil, FingerTree.t(), Digit.t()) :: DeepTree.t()
  def left(
        _pre,
        %EmptyTree{} = mid,
        %Digit4{meter_object: meter_object} = post
      ) do
    f = Tree.first(post)
    r = Tree.rest(post)
    s = Tree.first(r)
    deep(Digit.new(meter_object, f, s), mid, Tree.rest(r))
  end

  def left(
        _pre,
        %EmptyTree{} = mid,
        %_{meter_object: meter_object} = post
      ) do
    deep(Digit.new(meter_object, Tree.first(post)), mid, Tree.rest(post))
  end

  def left(
        _pre,
        mid,
        post
      ) do
    # not packing first of mid into digit
    deep(Tree.first(mid), Tree.rest(mid), post)
  end

  @spec right(Digit.t(), EmptyTree.t() | SingleTree.t(), Digit.t()) :: t()
  def right(pre, mid, %{a: _} = post) do
    deep(pre, mid, post)
  end

  def right(
        %Digit1{a: a, meter_object: meter_object},
        %EmptyTree{},
        _post
      ) do
    SingleTree.new(meter_object, a)
  end

  def right(
        %Digit4{meter_object: meter_object} = pre,
        %EmptyTree{} = mid,
        _post
      ) do
    f = Tree.first(pre)
    r = Tree.rest(pre)
    s = Tree.first(r)
    deep(Digit.new(meter_object, f, s), mid, Tree.rest(r))
  end

  def right(
        %_{meter_object: meter_object} = pre,
        %EmptyTree{} = mid,
        _post
      ) do
    deep(Digit.new(meter_object, Tree.first(pre)), mid, Tree.rest(pre))
  end

  def right(
        pre,
        mid,
        _post
      ) do
    # not packing first of mid into digit
    deep(pre, Tree.butlast(mid), Tree.last(mid))
  end

  @spec glue(FingerTree.t(), [term()], FingerTree.t()) :: FingerTree.t()
  def glue(%EmptyTree{}, xs, tree),
    do: xs |> List.foldr(tree, fn x, tree -> Conjable.cons(tree, x) end)

  def glue(tree, xs, %EmptyTree{}),
    do: xs |> List.foldl(tree, fn x, tree -> Conjable.conj(tree, x) end)

  def glue(%SingleTree{value: a}, xs, tree),
    do: [a | xs] |> List.foldr(tree, fn x, tree -> Conjable.cons(tree, x) end)

  def glue(tree, xs, %Digit1{a: a}),
    do: (xs ++ [a]) |> List.foldl(tree, fn x, tree -> Conjable.conj(tree, x) end)

  def glue(
        %DeepTree{meter_object: meter_object1, pre: t1_pre, mid: t1_mid, post: t1_post},
        xs,
        %DeepTree{meter_object: meter_object2, pre: t2_pre, mid: t2_mid, post: t2_post}
      )
      when meter_object1 == meter_object2 do
    xs =
      [
        Tree.to_reverted_list(t2_pre)
        | [Enum.reverse(xs) | Tree.to_reverted_list(t1_post)]
      ]
      |> revert()
      |> List.flatten()

    digits = DeepTree.to_digits(meter_object1, xs)

    deep(
      t1_pre,
      glue(
        t1_mid,
        digits,
        t2_mid
      ),
      t2_post
    )
  end

  @spec to_digits(MeterObject.t(), [term]) :: [Digit.t()]
  def to_digits(%MeterObject{} = meter_object, xs) do
    xs
    |> Enum.chunk_every(3, 3)
    |> Enum.map(fn
      [a] -> Digit.new(meter_object, a)
      [a, b] -> Digit.new(meter_object, a, b)
      [a, b, c] -> Digit.new(meter_object, a, b, c)
    end)
  end

  @spec split(t(), (FingerTree.MeterObject.measure_result() -> boolean()), term()) ::
          {t() | FingerTree.EmptyTree.t(), term(), t() | FingerTree.EmptyTree.t()}
  def split(
        %DeepTree{
          meter_object: %MeterObject{opfn: opfn} = meter_object,
          pre: pre,
          mid: mid,
          post: post
        },
        predicate,
        acc
      ) do
    vpr = opfn.(acc, Measurable.measured(pre))

    if predicate.(vpr) do
      {l, x, r} = Tree.split(pre, predicate, acc)
      {to_tree(meter_object, l |> to_list()), x, left(r, mid, post)}
    else
      vm = opfn.(vpr, Measurable.measured(mid))

      if predicate.(vm) do
        {mid_l, mid_x, mid_r} = Tree.split(mid, predicate, vpr)
        {l2, x2, r2} = Tree.split(mid_x, predicate, opfn.(vpr, Measurable.measured(mid_l)))
        {right(pre, mid_l, l2), x2, left(r2, mid_r, post)}
      else
        {post_l, post_x, post_r} = Tree.split(post, predicate, vm)
        {right(pre, mid, post_l), post_x, to_tree(meter_object, to_list(post_r))}
      end
    end
  end

  defimpl Conjable do
    def conj(%DeepTree{meter_object: meter_object, pre: pre, mid: mid, post: post}, value) do
      case post do
        %Digit4{a: a, b: b, c: c, d: d} ->
          new_digit = Digit.new(meter_object, a, b, c)
          deep(pre, Conjable.conj(mid, new_digit), Digit.new(meter_object, d, value))

        _ ->
          deep(pre, mid, Conjable.conj(post, value))
      end
    end

    def cons(%DeepTree{meter_object: meter_object, pre: pre, mid: mid, post: post}, value) do
      case pre do
        %Digit4{a: a, b: b, c: c, d: d} ->
          new_digit = Digit.new(meter_object, b, c, d)
          deep(Digit.new(meter_object, value, a), Conjable.cons(mid, new_digit), post)

        _ ->
          deep(Conjable.cons(pre, value), mid, post)
      end
    end
  end

  defimpl Measurable do
    def meter(%DeepTree{meter_object: meter_object}), do: meter_object
    def measured(%DeepTree{meterfn: meterfn}), do: meterfn.()
  end

  defimpl Tree do
    def first(%DeepTree{pre: %_{a: a}}), do: a

    def rest(%DeepTree{pre: pre, mid: mid, post: post}),
      do: DeepTree.left(Tree.rest(pre), mid, post)

    def last(%DeepTree{post: %_{d: d}}), do: d
    def last(%DeepTree{post: %_{c: c}}), do: c
    def last(%DeepTree{post: %_{b: b}}), do: b
    def last(%DeepTree{post: %_{a: a}}), do: a

    def butlast(%DeepTree{pre: pre, mid: mid, post: post}),
      do: DeepTree.right(pre, mid, Tree.butlast(post))

    def append(tree1, xs \\ [], tree2) do
      DeepTree.glue(tree1, xs, tree2)
    end

    def to_reverted_list(%DeepTree{pre: pre, mid: mid, post: post}),
      do: [
        Tree.to_reverted_list(post) | [Tree.to_reverted_list(mid) | Tree.to_reverted_list(pre)]
      ]

    def split(%DeepTree{} = tree, predicate, acc), do: DeepTree.split(tree, predicate, acc)
  end
end
