# The base class of all symbolic values
class SymbolicValue
  attr_accessor :name
  def initialize(name)
    @name = name
  end
  def ==(other)
    ConflictAnalysis.amb.choose(true,false)
  end
  def to_s
    # Except for nil and empty string, to_s never
    # returns an empty string. Hence, we pass false
    # here. In SymbolicString, we override this method.
    SymbolicString.new "#{name}.to_s", false
  end
  def to_i
    SymbolicInteger.new "#{name}.to_i"
  end
  def method_missing(name, *args, &blk)
    ConflictAnalysis.meta_logger
        .info "#{self.class}##{name} missing. Receiver: #{self.name}"
  end
  def respond_to? *args
    return true if super
    ConflictAnalysis.meta_logger
        .info "#{self.class}#respond_to?(#{args}). Receiver #{self.name}"
    false
  end
end