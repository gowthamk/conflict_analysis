class NilClass
  # See Tracer.tracing and Tracer.not_tracing to
  # understand how these methods are used.
  # Cannot override to_s to return "nil", as this
  # simple act modifies the control-flow of Rails!
  def to_empty_s
    ""
  end
  def to_nil_s
    "nil"
  end
end