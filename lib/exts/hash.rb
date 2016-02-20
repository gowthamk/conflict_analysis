class Hash

  class SymbolicKV
    attr_accessor :key, :value
    def initialize(k,v)
      @key = k
      @value = v
    end
  end

  alias_method :real_initialize, :initialize
  alias_method :real_insert, :[]=
  alias_method :real_lookup, :[]
  alias_method :real_keys, :keys
  alias_method :real_each, :each

  class << self
    alias_method :real_new_literal, :[]
    def [](*args)
      if args.length == 1 and args[0].is_a? Array
        hash = Hash.new
        args[0].each do |kvpair|
          hash[kvpair[0]]=kvpair[1]
        end
        return hash
      elsif args.length == 1 and args[0].is_a? SymbolicValue
        fail "Hash[ SymbolicValue ] form Unimpl."
      elsif args.length == 1
        real_new_literal(args[0])
      elsif args.length.modulo(2) ==0
        i = 0; hash = Hash.new
        (args.length.div 2).times do
          hash[args[i]]=args[i+1]
          i = i+2
        end
        return hash
      else
        fail "Unknown form of Hash::[]"
      end
    end
  end


  def initialize(*args,&block)
    @sym_kvs = []
    real_initialize(*args,&block)
  end

  def sym_kvs
    @sym_kvs ||= []
  end

  def []=(new_k,new_v)
    return real_insert(new_k,new_v) unless new_k.hash.is_a? SymbolicValue
    #puts "new_k is #{new_k.ast.to_s}"
    key_found = false
    self.sym_kvs.each do |sym_kv|
      if sym_kv.key == new_k
        key_found = true
        sym_kv.value = new_v
        break
      end
    end
    if !key_found then sym_kvs.push(SymbolicKV.new(new_k,new_v)) end
    new_v
  end

  def [](k)
    return real_lookup(k) unless k.hash.is_a? SymbolicValue
    self.sym_kvs.each do |sym_kv|
      if sym_kv.key == k
        return sym_kv.value
      end
    end
    nil
  end

  def each(&block)
    real_each(&block)
=begin
    self.sym_kvs.each do |sym_kv|
      yield(sym_kv.key,sym_kv.value)
    end
=end
  end

  def keys
    real_keys + (self.sym_kvs.map {|sym_kv| sym_kv.key})
  end

  def to_s
    "{#{self.to_a.map { |kv|
      "#{kv[0].to_s} => #{kv[1].to_s}"
    }.join ",\n"}}"
  end

  def freeze
    # Sorry, no.
    self
  end
end