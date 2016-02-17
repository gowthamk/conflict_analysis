module SymbolicEnumerable
  def map
    res = []
=begin
    map_ast = TraceAST::Map.new(self.ast,self.sym_value)
    res_ast = tracer.new_var_for(map_ast)
    res_val = yield self.sym_value
    tracer.trace(res_val)
    tracer.trace(TraceAST::End.new)
=end
    self.each do |v|
      res.push(yield v)
    end
    res
  end
end