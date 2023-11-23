defprotocol FingerTree.Protocols.Conjable do
  def conj(tree, value)
  def cons(tree, value)
end
