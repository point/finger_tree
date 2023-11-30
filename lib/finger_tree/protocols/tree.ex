defprotocol FingerTree.Protocols.Tree do
  def first(tree)
  def rest(tree)
  def to_recursive_reverted_list(tree)
  def last(tree)
  def butlast(tree)
  def append(tree1, tree2)
  def split(tree, predicate, acc)
  def to_list(tree)
end
