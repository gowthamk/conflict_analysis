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