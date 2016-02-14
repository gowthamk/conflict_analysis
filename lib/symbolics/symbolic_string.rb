class SymbolicString < SymbolicEmptinessValue

  def length
    SymbolicInteger.new "#{name}.length"
  end

  def to_s
    self
  end

  def =~(regex)
    ConflictAnalysis.amb.choose(true,false)
  end

  def !~(regex)
    ConflictAnalysis.amb.choose(true,false)
  end

  def downcase
    self
  end

  def [](*args)
    if args.length > 2 then
      ConflictAnalysis.meta_logger
          .info "SymbolicString#[] called with #{args} on #{name}"
      return self
    end
    case args[0]
      when Fixnum
        (self.is_empty==false and args[0]==0) ?
            (SymbolicNonEmptyString.new "#{name}#{args[0]}") :
            (nil_or_new_string args)
      when Range
        (self.is_empty == false and args[0].include? 0) ?
            (SymbolicNonEmptyString.new "#{name}#{args[0]}") :
            (nil_or_new_string args)
      else
        nil_or_new_string args
    end
  end

  private
  def nil_or_new_string args
    ConflictAnalysis.amb
        .choose (SymbolicString "#{name}[#{args}]", nil)
  end
end