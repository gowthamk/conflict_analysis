# A class to represent a symbolic row of given schema
class SymbolicRow < SymbolicValue
  def initialize(name,cols)
    super(name)
    @values = Array.new(cols.length) do |i|
      sym_val = SymbolicUntyped.new(cols[i])
      sym_val
    end
  end
  def name
    @name
  end
  def [](key)
    @values[key]
  end
end