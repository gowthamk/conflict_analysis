class SymbolicArray < SymbolicValue
  def initialize(name,sym_val,logger)
    super(name)
    @sym_value = sym_val
    @logger = logger
  end

  def map
    @logger.debug("#{@name}.map do |#{@sym_value.name}|")
    x = yield @sym_value
    @logger.debug("end")
    SymbolicArray.new("#{@name}.map",x,@logger)
  end

  def each
    @logger.debug("#{@name}.each do |row|")
    x = yield @sym_value
    @logger.debug("end")
    self
  end
end