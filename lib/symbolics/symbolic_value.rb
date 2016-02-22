# The base class of all symbolic values
class SymbolicValue

  def self.to_ast(val)
    if val.is_a? SymbolicValue
      val.ast
    # The below elsif doesn't work because there are some inane
    # implementations of map (Arel::Attributes::Attribute, for e.g.)
    #elsif val.respond_to? :map
    elsif val.is_a? Array
      val.map {|vv| SymbolicValue.to_ast(vv)}
    else
      ConflictAnalysis.meta_logger
          .info("SymbolicValue#to_ast called with #{val.to_s}")
      val
    end
  end

  attr_accessor :ast
  attr_reader :equal_vals, :inequal_vals

  def initialize(ast)
    fail 'SymbolicValue needs a TraceAST' unless TraceAST.a_si?(ast)
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

  # We assume that inspect is only for meta purpose
  def inspect
    self.ast.to_s
  end
  # We cache the results of to_s and to_i. Since each process has
  # its own copy of every SymbolicValue, and a process corresponds
  # to a linear path in the trace, the cached function results are
  # always well-formed (as per the trace program semantics) as long
  # as the process is live.
  def to_s
    # Ideally, SymbolicValues shouldn't escape into trace world, and
    # we shouldn't require this if condition. However, they do escape.
    # This is because of the symbolic values being stored in concrete
    # hashes and arrays in SymbolicResult#each or SymbolicArray#map.
    if tracer.tracing?
      return self.ast.to_s
    end
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

  def hash()
    @hash ||= begin
      hash_var = TraceAST::Var.new("hash")
      var = tracer.new_var_for(TraceAST::Dot.new(self.ast,hash_var))
      SymbolicInteger.new var
    end
  end

  def eql?(other)
    if other.is_a? SymbolicValue and self.hash.ast.to_s == other.hash.ast.to_s
      return true
    end
    bool_op = TraceAST::BoolOp.new(self.ast,'eql?',regex)
    var = tracer.new_var_for(bool_op)
    amb.choose(var, true,false)
  end


  def method_missing(name, *args, &blk)
    ca.meta_logger
        .info "#{self.class}##{name} missing. Receiver: #{self.ast.to_s}"
    super
  end

  def respond_to?(*args)
    return true if super
    ca.meta_logger
        .info "#{self.class}#respond_to?(#{args}). Receiver #{self.ast.to_s}"
    false
  end

  def <=>(other)
    ca.meta_logger.info "#{self.ast.to_s} <=> with #{other.to_s}"
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