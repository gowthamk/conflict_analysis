class Tracer < Logger
  attr_accessor :indent, :uid, :var_base
  def initialize(file)
    super(file)
    self.level= INFO
    self.indent = 0
    self.uid = 0
    self.var_base = "v"
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
  def var_for(expr)
    var = "#{self.var_base}#{self.uid}"
    self.uid = self.uid + 1
    trace(:assign,var,expr)
    return var
  end
  def trace(ast,*args)
    case ast
      when :if
        test = args[0]; val = args[1];
        cond = "#{test}==#{val}"
        self.info("#{self.indent_str}if(#{cond}) {")
        self.indent=self.indent+1
      when :else
        self.info("#{self.indent_str}else")
        self.indent=self.indent+1
      when :sql
        sql = args[0]
        self.info("#{self.indent_str}#{sql}")
      when :assign
        var = args[0]; expr = args[1];
        self.info("#{self.indent_str}#{var} := #{expr}")
    end
  end
  def end_all
    self.indent = self.indent - 1
    self.info("#{indent_str}}")
  end
end