class SymbolicInteger < SymbolicValue
  def initialize(ast)
    super
  end
  def to_i
    self
  end
  def <(other_ast)
    bool_op = TraceAST::BoolOp.new(self.ast,'<',other_ast)
    var = tracer.new_var_for(bool_op)
    amb.choose(var, true,false)
  end
  def >(other_ast)
    bool_op = TraceAST::BoolOp.new(self.ast,'>',other_ast)
    var = tracer.new_var_for(bool_op)
    amb.choose(var,true,false)
  end
  def <=(other_ast)
    bool_op = TraceAST::BoolOp.new(self.ast,'<=',other_ast)
    var = tracer.new_var_for(bool_op)
    amb.choose(var,true,false)
  end
  def >=(other_ast)
    bool_op = TraceAST::BoolOp.new(self.ast,'>=',other_ast)
    var = tracer.new_var_for(bool_op)
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