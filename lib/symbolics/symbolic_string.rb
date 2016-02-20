class SymbolicString < SymbolicEmptinessValue

  def length
    len_var = TraceAST::Var.new("length")
    var = tracer.new_var_for(TraceAST::Dot.new(self.ast,len_var))
    SymbolicInteger.new var
  end

  def to_s
    # For tracer, reveal who you really are...
    return self.ast.to_s if tracer.tracing?
    # Otherwise, maintain the bluff...
    self
  end

  def =~(regex)
    bool_op = TraceAST::BoolOp.new(self.ast,'=~',regex)
    var = tracer.new_var_for(bool_op)
    amb.choose(var,true,false)
  end

  def !~(regex)
    bool_op = TraceAST::BoolOp.new(self.ast,'=~',regex)
    var = tracer.new_var_for(bool_op)
    amb.choose(var, true,false)
  end

  def downcase
    self
  end

  def gsub(*args)
    self
  end

  def [](*args)
    if args.length > 2
      ca.meta_logger
          .info "SymbolicString#[] called with #{args} on #{name}"
      return self
    end
    case args[0]
      when Fixnum
        if self.is_empty==false and args[0]==0
          meth_ast = TraceAST::Var.new("#{args}")
          var = tracer.new_var_for(TraceAST::Dot.new(self.ast,meth_ast))
          SymbolicNonEmptyString.new var
        else
          nil_or_new_string args
        end
      when Range
        if self.is_empty == false and args[0].include? 0
          meth_ast = TraceAST::Var.new("#{args}")
          var = tracer.new_var_for(TraceAST::Dot.new(self.ast,meth_ast))
          SymbolicNonEmptyString.new var
        else
          nil_or_new_string args
        end
      else
        nil_or_new_string args
    end
  end

  private
  def nil_or_new_string(args)
    meth_ast = TraceAST::Var.new("#{args}")
    var = tracer.new_var_for(TraceAST::Dot.new(self.ast,meth_ast))
    amb.choose (SymbolicString.new var), nil
  end
end