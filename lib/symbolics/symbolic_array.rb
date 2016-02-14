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
    SymbolicArray.new("#{@name}.map",x,@logger)
  end

  def each
    #@logger.debug("#{@name}.each do |row|")
    x = yield sym_value
    #@logger.debug("end")
    self
  end

  def first
    ConflictAnalysis.amb.choose(nil, sym_value)
  end

  def to_s
    SymbolicNonEmptyString.new "#{name}.to_s"
  end

end