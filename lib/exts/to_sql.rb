module Arel
  module Visitors
    class ToSql
      def method_missing(name, *args, &blk)
        return super unless (name =~ /^visit_Symbolic/) or (name =~ /^visit_Struct_/)
        quote(*args)
        #args[0] = args[0].ast.to_s
        #return quoted(*args)
        #ConflictAnalysis.meta_logger
        #    .info "#{self.class}##{name} missing. Receiver: #{self.name}"
      end
    end
  end
end