class SymbolicInteger < SymbolicValue
  def to_i
    self
  end
  def <(other)
    ConflictAnalysis.amb.choose(true,false)
  end
  def >(other)
    ConflictAnalysis.amb.choose(true,false)
  end
  def <=(other)
    ConflictAnalysis.amb.choose(true,false)
  end
  def >=(other)
    ConflictAnalysis.amb.choose(true,false)
  end
  def ==(other)
    ConflictAnalysis.amb.choose(true,false)
  end
end