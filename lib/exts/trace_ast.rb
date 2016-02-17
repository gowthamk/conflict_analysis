module TraceAST
  # The difference between TraceAST and an AST is that a
  # TraceAST represents a partial expression that fits inside
  # a single line of trace.

  # Variable fits on a single line
  Var = Struct.new("Var",:name) do
    def to_s
      "#{self.name.to_s}"
    end
  end

  # Method call
  Dot = Struct.new("Dot",:receiver,:msg) do
    def to_s
      "#{self.receiver.to_s}.#{self.msg.to_s}"
    end
  end

  # Boolean operation, such as equalities and inequalities
  BoolOp = Struct.new("BoolOp",:lhs,:op,:rhs) do
    def to_s
      "#{self.lhs.to_s}#{self.op.to_s}#{self.rhs.to_s}"
    end
  end

  # Only the condition fits on a single line. Body on following lines.
  If = Struct.new("If",:cond) do
    def to_s
      "if (#{self.cond.to_s}) then"
    end
  end

  Else = Struct.new("Else") do
    def to_s
      "else"
    end
  end

  End = Struct.new("End") do
    def to_s
      "end"
    end
  end

  # A SQL query is considered to be a single line expression
  SQL = Struct.new("SQL",:query) do
    def to_s
      query.to_s
    end
  end

  # Assignment assigns a TraceAST to a variable
  Assignment = Struct.new("Assignment",:var,:rhs) do
    def to_s
      "#{self.var.to_s} := #{self.rhs.to_s}"
    end
  end

  # Header of a map expression.
  Map = Struct.new("Map",:list, :bv) do
    def to_s
      "#{self.list.to_s}.map do |#{self.bv.to_s}|"
    end
  end

  def self.a_si(ast)
    case ast
      when Var, Dot, BoolOp, If, Else, End, SQL, Assignment, Map
        true
      else
        false
    end
  end

end