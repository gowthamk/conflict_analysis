class SymbolicString < SymbolicEmptinessValue

  def length
    var = tracer.var_for "#{name}.length"
    SymbolicInteger.new var
  end

  def to_s
    self
  end

  def =~(regex)
    var = tracer.var_for "#{name} =~ #{regex}"
    amb.choose(var,true,false)
  end

  def !~(regex)
    var = tracer.var_for "#{name} !~ #{regex}"
    amb.choose(var, true,false)
  end

  def downcase
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
          var = tracer.var_for "#{name}#{args}"
          SymbolicNonEmptyString.new var
        else
          nil_or_new_string args
        end
      when Range
        if self.is_empty == false and args[0].include? 0
          var = tracer.var_for "#{name}#{args}"
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
    var = tracer.var_for "#{name}#{args}"
    amb.choose (SymbolicString.new var), nil
  end
end