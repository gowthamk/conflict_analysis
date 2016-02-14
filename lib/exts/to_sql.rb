module Arel
  module Visitors
    class ToSql
      def method_missing(name, *args, &blk)
        return super unless name =~ /^visit_Symbolic/
        return args[0].name
        #ConflictAnalysis.meta_logger
        #    .info "#{self.class}##{name} missing. Receiver: #{self.name}"
      end
    end
  end
end
