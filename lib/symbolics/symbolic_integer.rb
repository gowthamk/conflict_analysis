class SymbolicInteger < SymbolicValue
  def to_i
    self
  end
  def <(other)
    var = tracer.var_for "#{name}<#{other}"
    amb.choose(var, true,false)
  end
  def >(other)
    var = tracer.var_for "#{name}>#{other}"
    amb.choose(var,true,false)
  end
  def <=(other)
    var = tracer.var_for "#{name}<=#{other}"
    amb.choose(var,true,false)
  end
  def >=(other)
    var = tracer.var_for "#{name}>=#{other}"
    amb.choose(var,true,false)
  end
=begin
  # SymbolicValue already provides this method
  def ==(other)
    var = tracer.var_for "#{name}==#{other}"
    amb.choose(true,false)
  end
=end
end