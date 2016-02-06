class SymbolicUntyped < SymbolicValue
  def initialize(name)
    super(name)
  end
  def to_s
    self.name
  end
  def to_i(*args)
    SymbolicInteger.new("#{@name}.to_i")
  end
  def method_missing(name, *args, &blk)
    puts "#{name} method is missing"
    #puts caller
  end
  def respond_to? *args
    puts "Called respond_to? with #{args}"
    x = super
    puts "Returning #{x}"
    x
  end
end