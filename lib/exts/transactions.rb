module ActiveRecord
  # See ActiveRecord::Transactions::ClassMethods for documentation.
  module Transactions
    module ClassMethods
      alias_method :real_with_transaction_returning_status, :with_transaction_returning_status
      def with_transaction_returning_status
        status = real_with_transaction_returning_status
      end
    end
  end
end
