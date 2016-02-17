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

  def trace(ast)
    self.tracing
    case ast
      when TraceAST::If, TraceAST::Else, TraceAST::Map
        self.info("#{self.indent_str}#{ast.to_s}")
        self.indent=self.indent+1
      when TraceAST::End
        self.indent = self.indent - 1
        self.info("#{self.indent_str}#{ast.to_s}")
      when TraceAST::Assignment
        self.info("#{self.indent_str}#{ast.to_s}")
        self.indent=self.indent+1 if ast.rhs.is_a? TraceAST::Map
      else
        ast_str = ast.to_s
        self.info("#{self.indent_str}#{ast_str}")
    end
    if !TraceAST.a_si(ast)
      ConflictAnalysis.meta_logger.info("Unknown TraceAST: #{ast.to_s}")
    end
    self.not_tracing
  end

  def mark_indent
    self.begin_indent = self.indent
  end

  def end_all
    (self.indent - self.begin_indent - 1).times do
      self.indent = self.indent - 1
      self.info("#{indent_str}#{TraceAST::End.new().to_s}")
    end
  end
end