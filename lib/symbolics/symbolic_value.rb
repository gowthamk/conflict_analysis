# The base class of all symbolic values
class SymbolicValue
  attr_accessor :name
  def initialize(name)
    @name = name
  end
  def ==(other)
    puts "#{name} was compared to #{other}"
  end
  def to_s
    self.name.to_s
  end
  def method_missing(name, *args, &blk)
    puts "Method #{name} is missing on a the symbolic value #{self.name}"
  end
end