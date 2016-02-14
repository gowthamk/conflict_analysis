class SymbolicArray < SymbolicEmptinessValue
  attr_reader :sym_value
  def initialize(name, sym_val, is_empty=nil)
    super(name,is_empty)
    @sym_value = sym_val
  end

  def map
    #@logger.debug("#{@name}.map do |#{sym_value.name}|")
    x = yield sym_value
    #@logger.debug("end")
    var = tracer.var_for "#{self.name}.map"
    SymbolicArray.new(var,x,self.is_empty)
  end

  def each
    #@logger.debug("#{@name}.each do |row|")
    x = yield sym_value
    #@logger.debug("end")
    self
  end

  def first
    var = tracer.var_for "#{name}.first"
    amb.choose(var, nil, sym_value)
  end

  def to_s
    var = tracer.var_for "#{name}.to_s"
    SymbolicNonEmptyString.new var
  end

end