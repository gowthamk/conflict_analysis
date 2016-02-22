module Arel
  module Nodes

    class Binary
      alias_method :real_initialize, :initialize
      def initialize(left, right)
        new_left = SymbolicValue.to_ast left
        new_right = SymbolicValue.to_ast right
        real_initialize(new_left, new_right)
      end
    end

    class Function
      alias_method :real_initialize, :initialize
      def initialize(expr, aliaz = nil)
        new_expr = SymbolicValue.to_ast(expr)
        real_initialize(new_expr,aliaz)
      end
    end

    class Unary
      alias_method :real_initialize, :initialize
      def initialize(expr)
        new_expr = SymbolicValue.to_ast(expr)
        real_initialize(expr)
      end
    end

    # For INSERT statements, exec_query is acting as the interface.
    # Otherwise, we will have to override Arel::Nodes::InsertStatement here.

  end
end