# The base class of all symbolic values
class SymbolicValue
  attr_accessor :ast
  attr_reader :equal_vals, :inequal_vals
  def initialize(ast)
    fail 'SymbolicValue needs a TraceAST' unless TraceAST.a_si(ast)
    @ast = ast
    @equal_vals = []
    @inequal_vals = []
  end

  def ==(other_val)
    if SymbolicValue===other_val
      return self.sym_equal(other_val)
    end
    if self.equal_vals.include?(other_val)
      return true
    elsif self.inequal_vals.include?(other_val)
      return false
    end
    bool_op = TraceAST::BoolOp.new(self.ast,'==',other_val)
    var = tracer.new_var_for(bool_op)
    is_eq = ca.amb.choose(var,true,false)
    if is_eq
      self.equal_vals.push(other_val)
    else
      self.inequal_vals.push(other_val)
    end
    is_eq
  end

  def to_s
    # For tracer, reveal who you really are.
    return self.ast.to_s if tracer.tracing?
    # Otherwise, maintain the bluff...
    to_s_var = TraceAST::Var.new("to_s")
    var = tracer.new_var_for(TraceAST::Dot.new(self.ast,to_s_var))
    # Except for nil and empty string, to_s never
    # returns an empty string.
    SymbolicNonEmptyString.new var
  end

  def to_i
    to_i_var = TraceAST::Var.new("to_i")
    var = tracer.new_var_for(TraceAST::Dot.new(self.ast,to_i_var))
    SymbolicInteger.new var
  end

  def method_missing(name, *args, &blk)
    ca.meta_logger
        .info "#{self.class}##{name} missing. Receiver: #{self.ast.to_s}"
  end

  def respond_to?(*args)
    return true if super
    ca.meta_logger
        .info "#{self.class}#respond_to?(#{args}). Receiver #{self.ast.to_s}"
    false
  end

  protected
  def ca
    ConflictAnalysis
  end

  def amb
    ConflictAnalysis.amb
  end

  def tracer
    ConflictAnalysis.tracer
  end

  private
  def sym_equal(other_sym_val)
    bool_op = TraceAST::BoolOp.new(self.ast,'==',other_sym_val)
    var = tracer.new_var_for(bool_op)
    return ca.amb.choose(var,true,false)
  end
end