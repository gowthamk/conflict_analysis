class SymbolicArray < SymbolicEmptinessValue
  attr_reader :sym_value
  def initialize(name, sym_val, is_empty=nil)
    super(name,is_empty)
    @sym_value = sym_val
  end

  def map
    #@logger.debug("#{@name}.map do |#{sym_value.name}|")
    map_ast = TraceAST::Map.new(self.ast,self.sym_value)
    res_ast = tracer.new_var_for(map_ast)
    res_val = yield self.sym_value
    tracer.trace(res_val)
    tracer.trace(TraceAST::End.new)
    SymbolicArray.new(res_ast, res_val, self.is_empty)
  end

  def each
    #@logger.debug("#{@name}.each do |row|")
    x = yield sym_value
    ConflictAnalysis.meta_logger.info("method each called on #{self}")
    #@logger.debug("end")
    self
  end

  def first
    meth_ast = TraceAST::Var.new("first")
    var = tracer.new_var_for(TraceAST::Dot.new(self.ast,meth_ast))
    amb.choose(var, nil, sym_value)
  end

  def to_s
    meth_ast = TraceAST::Var.new("to_s")
    var = tracer.new_var_for(TraceAST::Dot.new(self.ast,meth_ast))
    SymbolicNonEmptyString.new var
  end

end