# FingerTree

A pure Elixir implementation of the [Finger Tree](http://www.staff.city.ac.uk/~ross/papers/FingerTree.html) data structure.
Finger Tree is a functional sequence data structure with amortized constant-time access and appending to the front and end of the sequence.
It provides logarithmic time concatenation and random access.

| Operation | Cost     | Amortized |
| --------- | -------- | --------- |
| head      | O(1)     | O(1)      |
| tail      | O(log n) | O(1)      |
| cons      | O(log n) | O(1)      |
| conj      | O(log n) | O(1)      |
| last      | O(1)     | O(1)      |
| butlast   | O(log n) | O(1)      |
| new       | O(log n) | O(1)      |
| concat    | O(log n) | O(log n)  |
| count     | O(1)     | O(1)      |

Finger trees combine several features that make them pretty versatile:
* Purity. This is purely functional data structure
* Flexibility. Finger tree can hold any Elixir data structure. But also, you can build your own abstractions with described amortized complexity 
  based on finger tree. See [Seq]() and [SortedSet]()
* Efficiency. Finger trees have efficient random-access and tree (sequence) split complexity. Also, O(1) count measurement.

The best graphical representation of Finger Trees presented is in the paper:
[![finger tree](https://www.staff.city.ac.uk/~ross/papers/FingerTree/example-tree.svg)](https://www.staff.city.ac.uk/~ross/papers/FingerTree.html)


This library is built using Elixir protocols and heavily inspired by the Clojure implementation [clojure.data.finger-tree](https://github.com/clojure/data.finger-tree).
The goal is to have a handy building block to construct domain-specific data structures on top of the finger tree.

## Examples

### Finger Tree -based sequence

Supports efficient insertion from both left and right ends, random access and length detection.

```elixir
iex(1)> alias Seq
iex(2)> seq = 1..10 |> Enum.into(Seq.new())
iex(3)> Seq.first(seq)
1
iex(4)> seq |> Seq.cons(0) |> Seq.to_list()
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
iex(5)> seq |> Seq.conj(11) |> Seq.to_list()
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
iex(6)> seq |> Seq.rest() |> Seq.to_list()
[2, 3, 4, 5, 6, 7, 8, 9, 10]
iex(7)> seq |> Seq.butlast() |> Seq.to_list()
[1, 2, 3, 4, 5, 6, 7, 8, 9]
iex(8)> seq |> Seq.at(3)
4
iex(9)> {l, value, r} = seq |> Seq.split(fn pos -> pos >= 3 end)
iex(10)> Seq.to_list(l)
[1, 2]
iex(11)> value
3
iex(12)> Seq.to_list(r)
[4, 5, 6, 7, 8, 9, 10]
iex(13)> l |> Seq.append(r) |> Seq.to_list()
[1, 2, 4, 5, 6, 7, 8, 9, 10]
```

### Finger Tree -based sorted set

```elixir
iex(1)> alias FingerTree.SortedSet
iex(2)> set = SortedSet.new([1, 3, 5, 2, 4, 6])
iex(3)> set |> SortedSet.to_list()
[1, 2, 3, 4, 5, 6]
iex(4)> SortedSet.member?(set, 5)
true
iex(5)> set |> SortedSet.put(1) |> SortedSet.to_list()
[1, 2, 3, 4, 5, 6]
iex(6)> set |> SortedSet.reject(6) |> SortedSet.to_list()
[1, 2, 3, 4, 5]
iex(7)> set |> SortedSet.append(SortedSet.new([7, 0])) |> SortedSet.to_list()
[0, 1, 2, 3, 4, 5, 6, 7]
iex(8)> {l, value, r} = SortedSet.split_at(set, 3)
iex(9)> SortedSet.to_list(l)
[1, 2, 3]
iex(10)> value
4
iex(11)> SortedSet.to_list(r)
[5, 6]
```

## Installation

```elixir
def deps do
  [
    {:finger_tree, git: "https://github.com/point/finger_tree.git", branch: "main"}
  ]
end
```

## Deep dive

Except the paper itself, there are few good resources about the data structure and algorithms behind it:

1. Awesome step-by-step video explainer [Finger Trees Explained Anew, and Slightly Simplified (Functional Pearl) Haskell 2020](https://www.youtube.com/watch?v=ip92VMpf_-A) on YouTube
2. Great explanation of Clojure's clojure.data.finger-tree concepts [Finger Trees Custom Persistent Collections - Chris Houser](https://www.youtube.com/watch?v=UXdr_K0Lwg4) on YouTube 
3. Blog post with explanation and examples in Java [Finger Trees](https://maniagnosis.crsr.net/2010/11/finger-trees.html)
4. Another implementation of Finger Trees in Elixir [hallux](https://github.com/thalesmg/hallux)


## License
MIT

## TODO
- [ ] Build-your-own finger tree examples
- [ ] Property-based test
- [ ] hex.pm package and documentation
