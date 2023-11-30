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
          mid: FingerTree.t(),
          post: Digit.t(),
          meterfn: (-> MeterObject.measure_result())
        }

  @spec new(
          MeterObject.t(),
          Digit.t(),
          FingerTree.t(),
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

  @spec right(Digit.t(), FingerTree.t(), Digit.t() | nil) :: FingerTree.t()
  def right(%_{meter_object: meter_object} = pre, %EmptyTree{}, nil) do
    to_tree(meter_object, to_list(pre))
  end

  def right(pre, %SingleTree{value: value, meter_object: meter_object}, nil) do
    deep(pre, EmptyTree.new(meter_object), value)
  end

  def right(pre, %DeepTree{pre: mid_pre, mid: mid_mid, post: %Digit1{a: a}}, nil) do
    deep(pre, right(mid_pre, mid_mid, nil), a)
  end

  def right(pre, %DeepTree{pre: mid_pre, mid: mid_mid, post: mid_post}, nil) do
    deep(pre, deep(mid_pre, mid_mid, Tree.butlast(mid_post)), Tree.last(mid_post))
  end

  def right(pre, mid, post), do: deep(pre, mid, post)

  def left(nil, %EmptyTree{}, %_{meter_object: meter_object} = post) do
    to_tree(meter_object, to_list(post))
  end

  @spec right(Digit.t() | nil, FingerTree.t(), Digit.t()) :: FingerTree.t()
  def left(nil, %SingleTree{meter_object: meter_object, value: value}, %_{} = post) do
    deep(value, EmptyTree.new(meter_object), post)
  end

  def left(nil, %DeepTree{pre: %Digit1{a: a}, mid: mid_mid, post: mid_post}, post) do
    deep(a, left(nil, mid_mid, mid_post), post)
  end

  def left(nil, %DeepTree{pre: pre, mid: mid_mid, post: mid_post}, post) do
    deep(Tree.first(pre), deep(Tree.rest(pre), mid_mid, mid_post), post)
  end

  def left(pre, mid, post), do: deep(pre, mid, post)

  @spec glue(FingerTree.t(), [term()], FingerTree.t()) :: FingerTree.t()
  def glue(%EmptyTree{}, xs, tree),
    do: xs |> List.foldr(tree, fn x, tree -> Conjable.cons(tree, x) end)

  def glue(tree, xs, %EmptyTree{}),
    do: xs |> List.foldl(tree, fn x, tree -> Conjable.conj(tree, x) end)

  def glue(%SingleTree{value: a}, xs, tree),
    do: [a | xs] |> List.foldr(tree, fn x, tree -> Conjable.cons(tree, x) end)

  def glue(tree, xs, %Digit1{a: a}),
    do: (xs ++ [a]) |> List.foldl(tree, fn x, tree -> Conjable.conj(tree, x) end)

  def glue(tree, xs, %SingleTree{value: a}),
    do: (xs ++ [a]) |> List.foldl(tree, fn x, tree -> Conjable.conj(tree, x) end)

  def glue(
        %DeepTree{meter_object: meter_object1, pre: t1_pre, mid: t1_mid, post: t1_post},
        xs,
        %DeepTree{meter_object: meter_object2, pre: t2_pre, mid: t2_mid, post: t2_post}
      )
      when meter_object1 == meter_object2 do
    xs2 = Tree.to_list(t1_post) ++ xs ++ Tree.to_list(t2_pre)

    digits = DeepTree.to_digits(meter_object1, xs2)

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
      {to_tree(meter_object, to_list(l)), x, left(r, mid, post)}
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

    def to_recursive_reverted_list(%DeepTree{pre: pre, mid: mid, post: post}),
      do: [
        Tree.to_recursive_reverted_list(post)
        | [Tree.to_recursive_reverted_list(mid) | Tree.to_recursive_reverted_list(pre)]
      ]

    def to_list(%DeepTree{pre: pre, mid: mid, post: post}), do: [pre, mid, post]

    def split(%DeepTree{} = tree, predicate, acc), do: DeepTree.split(tree, predicate, acc)
  end
end
