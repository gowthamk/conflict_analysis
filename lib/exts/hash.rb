class Hash
  def to_s
    "{#{self.to_a.map { |kv|
      "#{kv[0].to_s} => #{kv[1].to_s}"
    }.join ', '}}"
  end
end