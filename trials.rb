#puts "Hello".methods
puts 2.respond_to? :empty?
puts "hello".empty?
puts "".empty?
#puts nil.empty?# undefined method empty? for nil.

puts ("".empty?)? 2 : 3

puts "Hello"[0,255]

puts String==="Hello" #true
puts "Hello"===String #false!

case "Hello"
  when String
    puts "Hello is a string"
end

puts (nil == false)

puts "match: #{"doesn't match" unless ("visit_SymbolicString" =~ /^visit_Symbolic/)}"

case :if
  when :if
    puts "if is if"
end

x = 3
x.times do
  puts x
  x = x-1
end


ClassA = Struct.new(:field) do
  def to_s
    self.field
  end
end

a = ClassA.new(2)

case a
  when ClassA
    puts "#{a.to_s}"
end

class Hash
  def to_s
    "{#{self.to_a.map { |kv|
      "#{kv[0].to_s} => #{kv[1].to_s}"
    }.join ', '}}"
  end
end

h = {:a => a, :b => ClassA.new(3)}

puts "testing hash: #{h}"

class ClassB < ClassA
  def initialize(x)
    super
  end
end

b = ClassB.new 4
puts "ClassA===b? #{ClassA===b}"


# Can a non-nil/non-false object evaluate to
# false in if-then-else?
class Boolean
  def inspect
    puts "Boolean is being inspected"
    false
  end
  def ==(other)
    other.nil?
  end
  def ===(other)
    other.nil?
  end
  def nil?
    true
  end
  def empty?
    true
  end
  def blank?
    true
  end
end

my_bool = Boolean.new

b = ClassB.new my_bool

if my_bool
  puts "my_bool is true!"
else
  puts "my_bool is false"
end

# Apparently, never!

puts ("  hello\nworld".gsub(/\n/,"\n  "))