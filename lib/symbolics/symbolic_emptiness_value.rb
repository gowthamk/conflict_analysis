class SymbolicEmptinessValue < SymbolicValue
  attr_reader :is_empty

  def initialize(name,is_empty=nil)
    @is_empty = is_empty
    super(name)
  end

  def empty?
    (is_empty.nil?)? ConflictAnalysis.amb.choose(false,true) : is_empty
  end
end