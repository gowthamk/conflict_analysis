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
    return true if self.object_id == other_val.object_id
    return self.sym_equal(other_val) if SymbolicValue===other_val

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

  # We cache the results of to_s and to_i. Since each process has
  # its own copy of every SymbolicValue, and a process corresponds
  # to a linear path in the trace, the cached function results are
  # always well-formed (as per the trace program semantics) as long
  # as the process is live.
  def to_s
    # For tracer, reveal who you really are.
    return self.ast.to_s if tracer.tracing?
    # Otherwise, maintain the bluff...
    @to_s ||= begin
      to_s_var = TraceAST::Var.new("to_s")
      var = tracer.new_var_for(TraceAST::Dot.new(self.ast,to_s_var))
      # Except for nil and empty string, to_s never
      # returns an empty string.
      SymbolicNonEmptyString.new var
    end
  end

  def to_i
    @to_i ||= begin
      to_i_var = TraceAST::Var.new("to_i")
      var = tracer.new_var_for(TraceAST::Dot.new(self.ast,to_i_var))
      SymbolicInteger.new var
    end
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

  def sym_equal(other_sym_val)
    ca.meta_logger.info("Symbolic Comparision between #{self.ast} and #{other_sym_val.ast}")
    bool_op = TraceAST::BoolOp.new(self.ast,'==',other_sym_val)
    var = tracer.new_var_for(bool_op)
    return ca.amb.choose(var,true,false)
  end
end