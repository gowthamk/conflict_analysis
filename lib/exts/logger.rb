class Logger
  def error(*args)
    puts caller
    puts "Error raised with #{args}"
  end
end