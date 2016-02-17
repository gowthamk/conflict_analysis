class SymbolicNonEmptyString < SymbolicString
  def initialize ast
    super ast, false
  end
end