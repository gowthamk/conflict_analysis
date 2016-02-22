class Tracer < Logger
  attr_accessor :indent, :begin_indent, :uid,
                :var_base

  def tracing
    @tracing = true
  end

  def not_tracing
    @tracing = false
  end

  def tracing?
    @tracing
  end

  def initialize(file)
    super
    self.level= INFO
    self.indent = 0
    self.begin_indent = 0
    self.uid = 0
    self.var_base = "v"
    self.not_tracing
    self.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
  end

  def indent_str
    str=""
    self.indent.times do
      str = str + "  "
    end
    return str
  end

  def new_var_for(expr)
    v = self.new_var
    trace(TraceAST::Assignment.new(v,expr))
    return v
  end

  def new_var
    v = "#{self.var_base}#{self.uid}"
    self.uid = self.uid + 1
    TraceAST::Var.new(v)
  end

  # Caution: Be careful with the tracing flag if you are
  # making this method recursive.
  def trace(ast)
    self.tracing
    case ast
      when TraceAST::Def, TraceAST::If, TraceAST::Else, TraceAST::Map
        self.info("#{self.indent_str}#{ast.to_s}")
        self.indent=self.indent+1
      when TraceAST::End
        self.indent = self.indent - 1
        self.info("#{self.indent_str}#{ast.to_s}")
      when TraceAST::Assignment
        self.info("#{self.indent_str}#{ast.to_s}")
        self.indent=self.indent+1 if ast.rhs.is_a? TraceAST::Map
      else
        istr = self.indent_str
        indented_ast_str = istr + (ast.to_s.gsub(/\n/,"\n#{istr}"))
        self.info(indented_ast_str)
    end
    if !TraceAST.a_si?(ast)
      # We come here mostly because of Hashes and Arrays storing
      # SymbolicValues.
      ConflictAnalysis.meta_logger.info("Unknown TraceAST: #{ast.to_s}")
    end
    self.not_tracing
  end

  # mark_indent_for_if marks the begin indent for a process executing
  # an `if` TraceAST. It is the indent until which the process must
  # `end` before exiting.
  # If a process executes at least one `if` TraceAST, then it
  # should `end` with one less than the number of indents it has
  # created; an `else` TraceAST will end the last indent.
  def mark_indent_for_if
    self.begin_indent = self.indent + 1
  end

  # end_all restores the indent until the begin indent.
  def end_all
    (self.indent - self.begin_indent).times do
      self.indent = self.indent - 1
      self.info("#{indent_str}#{TraceAST::End.new().to_s}")
    end
  end
end