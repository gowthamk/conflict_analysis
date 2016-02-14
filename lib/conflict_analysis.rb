require "active_record"
require "conflict_analysis/version"
require "exts/exts"
require_relative '../amb/lib/amb'
require "symbolics/symbolics"
require "exts/database_adapter"

module ConflictAnalysis
  def self.amb=(amb)
    @@amb = amb
  end
  def self.amb
    @@amb
  end
  def self.meta_logger=(logger)
    @@meta_logger = logger
  end
  def self.meta_logger
    @@meta_logger
  end
  def self.init(config)
    my_logger = Logger.new('log/experiments.log')
    my_logger.level= Logger::DEBUG
    ActiveRecord::Base.logger = my_logger
    ActiveRecord::Base.establish_connection(config)
    self.meta_logger = Logger.new('log/meta.log')
    self.meta_logger.level = Logger::DEBUG
    dbname = config["adapter"]
    self.amb= Class.new {include Amb}.new
    # Note: ConnectionHandling module is "extend"ed in
    # ActiveRecord::Base. Hence, the new defn of sqlite3_connection
    # needs to be the instance method in the module.
    # Alternatively, it can also be a class method of
    # ActiveRecord::Base.
    ActiveRecord::ConnectionHandling.module_eval do
      alias_method :real_database_connection, "#{dbname}_connection".to_sym
      define_method "#{dbname}_connection".to_sym,
                    (DatabaseAdapter.instance_method :database_connection)
    end
  end

  def self.with_args_of_type(*types, proc)
    arg_names = proc.parameters.map {|p| p[1]}
    if !(arg_names.length == types.length) then
      fail "Invalid conflict spec"
    end
    args = arg_names.zip(types)
    sym_args = args.map {|arg| self.value_of_class(arg[0], arg[1])}
    begin
      proc.(*sym_args)
    rescue Exception
      sym_args.each do |arg|
        if arg.respond_to? :errors then
          puts arg.errors.full_messages
        end
      end
      raise
    end
  end

  private
  def self.value_of_class(name,cls)
    if cls == NilClass then
      nil
    elsif cls == TrueClass then
      true
    elsif cls == FalseClass then
      false
    elsif !cls.respond_to? :<= then
      SymbolicUntyped.new name
    elsif cls <= ActiveRecord::Base then
      symbol_of_model(name,cls)
    elsif cls <= Fixnum
      SymbolicInteger.new name
    elsif cls <= String
      SymbolicNonEmptyString.new name #We assume that user-provided strings are non-empty.
    elsif cls <= Boolean #Boolean is not a core class.
      # if its boolean, we choose a real value.
      self.amb.choose(true,false)
    else
      SymbolicUntyped.new name
    end
  end
  # @param name Symbol
  # @param cls Class
  # @return Symbol
  def self.symbol_of_model(name,cls)
    arsym = cls.new
    column_types = arsym.instance_eval {|| @column_types}
    column_types.each do |attr,column|
      attr_name = "#{name.to_s}.#{attr}".to_sym
      attr_sym_val = self.value_of_class attr_name, (class_of_type column.type)
      arsym.send("#{attr}=", attr_sym_val)
    end
    # Quick and dirty fix for `has_secure_password`.
    # TODO: Fixme
    if arsym.respond_to? :password= then
      arsym.password= SymbolicNonEmptyString.new "#{name}.password"
    end
    arsym
  end

  # @param type Symbol
  # @return Class
  def self.class_of_type type
    case type
      when :integer
        Fixnum
      when :string, :datetime
        String
      when :boolean
        Boolean
      else
        BasicObject
    end
  end
end
