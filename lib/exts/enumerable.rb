module Enumerable
  alias_method :real_group_by, :group_by
  def group_by
    if block_given?
      hash = {}
      self.each do |e|
        res = yield e
        if hash[res].nil? then hash[res] = [] end
        hash[res].push(e)
        x = 2
      end
    else
      hash = real_group_by
    end
    hash
  end
end