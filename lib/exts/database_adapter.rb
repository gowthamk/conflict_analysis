module DatabaseAdapter
  # exec_query is where all queries come to get dispatched to the DB.
  # Along with Arel::Nodes::Node constructors, exec_query is also
  # part of the Symbolic-Trace boundary, where SymbolicValues get
  # converted to TraceASTs. It plays this role for INSERT queries,
  # where values to be inserted come packaged as binds hash.
  def exec_query(sql, name=nil, binds=[])
    if name == "SCHEMA" then
      real_exec_query(sql,name,binds)
    else
      binds = SymbolicValue.to_ast(binds)
      tracer = ConflictAnalysis.tracer
      res_var = tracer.new_var_for(TraceAST::SQL.new(sql,binds))
      log(sql, name, binds) do
        stmt    = @connection.prepare(sql)
        cols = stmt.columns
        row_var = tracer.new_var
        row = SymbolicRow.new(row_var,cols)
        rows = SymbolicArray.new(res_var,row)
        #ActiveRecord::Result.new(cols, rows)
        SymbolicResult.new(cols, rows)
      end
    end
  end

  # 1. The following method must be executed in the context of (with self as)
  #    ActiveRecord::ConnectionHandling module,
  # 2. DatabaseAdapter module must be in scope, and
  # 3. Adapter-specific connection method must be renamed to `old_database_connection`
  def database_connection(config)
    if !self.respond_to? :real_database_connection
      fail "MonkeyPatching error: real_database_connection not defined!"
    end
    x = real_database_connection(config)
    x.instance_eval do
      define_singleton_method :real_exec_query, (self.method :exec_query)
      define_singleton_method :exec_query, (DatabaseAdapter.instance_method :exec_query)
      define_singleton_method :begin_db_transaction,
                              (DatabaseAdapter.instance_method :begin_db_transaction)
      define_singleton_method :commit_db_transaction,
                              (DatabaseAdapter.instance_method :commit_db_transaction)
      define_singleton_method :rollback_db_transaction,
                              (DatabaseAdapter.instance_method :rollback_db_transaction)
      define_singleton_method :real_type_cast, (self.method :type_cast)
      define_singleton_method :type_cast,
                              (DatabaseAdapter.instance_method :type_cast)
      define_singleton_method :real_quote, (self.method :quote)
      define_singleton_method :quote, (DatabaseAdapter.instance_method :quote)
    end
    x
  end

  def begin_db_transaction
    log('begin transaction') {}
    ConflictAnalysis.trace(TraceAST::SQL.new("begin transaction"))
  end

  def commit_db_transaction
    log('commit transaction') {}
    ConflictAnalysis.trace(TraceAST::SQL.new("commit transaction"))
    ConflictAnalysis.amb.failure
  end

  def rollback_db_transaction
    log('rollback transaction') {}
    ConflictAnalysis.trace(TraceAST::SQL.new("rollback transaction"))
    ConflictAnalysis.amb.failure
  end

  def type_cast(value, column)
    return real_type_cast(value, column) unless value.is_a? SymbolicValue
    value#.ast.to_s
  end

  def quote(value, column=nil)
    if value.is_a? SymbolicValue then
      q = "'#{quote_string(value.ast.to_s)}'"
    elsif TraceAST.a_si? value
      q = "'#{quote_string(value.to_s)}'"
    else
      q = real_quote(value, column)
    end
    q
  end

end