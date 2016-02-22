module Arel
  module Visitors
    class ToSql
      def method_missing(name, *args, &blk)
        return super unless (name =~ /^visit_Symbolic/) or (name =~ /^visit_Struct_/)
        if name =~ /^visit_Symbolic/ then
          msg = 'A SymbolicValue has found its way into Arel AST!'
          ConflictAnalysis.meta_logger.info msg
          fail msg
        end
        quote(*args)
      end
    end
  end
end