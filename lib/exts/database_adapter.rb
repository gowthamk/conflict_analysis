module DatabaseAdapter
  def exec_query(sql, name=nil, binds=[])
    if !self.respond_to? :real_exec_query then
      fail "MonkeyPatching error: real_exec_query is not defined!"
    end
    if name == "SCHEMA" then
      real_exec_query(sql,name,binds)
    else
      tracer = ConflictAnalysis.tracer
      res_var = tracer.new_var_for(TraceAST::SQL.new(sql))
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
    end
    x
  end

  def begin_db_transaction
    log('begin transaction') {}
    ConflictAnalysis.trace(TraceAST::SQL.new("begin transaction"))
  end

  def commit_db_transaction
    #fail "Test error"
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
    return real_type_cast(value, column) unless value.class <= SymbolicValue
    value.to_s
  end

end