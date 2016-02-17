class SymbolicEmptinessValue < SymbolicValue
  attr_reader :is_empty

  def initialize(ast,is_empty=nil)
    @is_empty = is_empty
    super(ast)
  end

  def empty?
    (is_empty.nil?)?
        (ca.choose(ca.tracer.new_var_for(TraceAST::Dot.new(self.ast,
                                                           TraceAST::Var.new("empty?"))), false, true)) :
        is_empty
  end
end