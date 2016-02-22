# Arel::Predications is an entry point to the Trace world from
# the Symbolic world. We hack it up to convert SymbolicValues to
# ASTs at the interface. This may not be a clean solution, but I
# don't see any alternatives as the boundary between Rails and SQL
# is not clearly defined.
module Arel
  module Predications

  end
end
