class Fixnum
  alias_method :lte, :<=
  alias_method :gte, :>=
  alias_method :eq_to, :==
  def <=(other)
    return lte(other) unless other.is_a? SymbolicInteger
    other > self
  end
  def >=(other)
    return gte(other) unless other.is_a? SymbolicInteger
    other < self
  end
  def ==(other)
    return eq_to(other) unless other.is_a? SymbolicInteger
    other == self
  end
end