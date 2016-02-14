# The base class of all symbolic values
class SymbolicValue
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def ==(other)
    var = tracer.var_for "#{name}==#{other}"
    ca.amb.choose(var,true,false)
  end

  def to_s
    # Except for nil and empty string, to_s never
    # returns an empty string. Hence, we pass false
    # here. In SymbolicString, we override this method.
    var = tracer.var_for "#{name}.to_s"
    SymbolicNonEmptyString.new var
  end

  def to_i
    var = tracer.var_for "#{name}.to_i"
    SymbolicInteger.new var
  end

  def method_missing(name, *args, &blk)
    ca.meta_logger
        .info "#{self.class}##{name} missing. Receiver: #{self.name}"
  end

  def respond_to?(*args)
    return true if super
    ca.meta_logger
        .info "#{self.class}#respond_to?(#{args}). Receiver #{self.name}"
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
end