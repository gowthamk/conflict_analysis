# A class to represent a symbolic row of given schema
class SymbolicRow < SymbolicValue
  def initialize(ast,cols)
    super(ast)
    @values = Array.new(cols.length) do |i|
      var_ast = TraceAST::Var.new(cols[i])
      dot_ast = TraceAST::Dot.new(ast,var_ast)
      sym_val = SymbolicUntyped.new(dot_ast)
      sym_val
    end
  end

  def [](key)
    @values[key]
  end
end