class SymbolicResult < SymbolicEmptinessValue
  attr_reader :columns, :rows, :column_types

  def initialize(columns, rows, column_types = {})
    super "SymbolicResult", nil # Result can always be empty. Hence nil.
    @columns      = columns
    @rows         = rows
    @hash_rows    = nil
    @column_types = column_types
  end

  def each
    hash = hash_rows
    hash.each { |row| yield row }
  end

  def to_hash
    hash_rows
  end

  # TODO: Include Enumerate
  # alias :map! :map
  # alias :collect! :map

  def to_ary
    hash_rows
  end

  def [](idx)
    ca.meta_logger.info '[] called on symbolic result'
    hash_rows[idx]
  end

  def first
    hash_rows.first
  end

  def last
    hash_rows.last
  end

  def result
    x= 1
    y = x+1
  end

  def initialize_copy(other)
    @columns   = columns.dup
    @rows      = rows.dup
    @hash_rows = nil
  end

  private
  def hash_rows
    @hash_rows ||=
        begin
          # We freeze the strings to prevent them getting duped when
          # used as keys in ActiveRecord::Base's @attributes hash
          columns = @columns.map { |c| c.dup.freeze }
          @rows.map { |row|
            # In the past we used Hash[columns.zip(row)]
            #  though elegant, the verbose way is much more efficient
            #  both time and memory wise cause it avoids a big array allocation
            #  this method is called a lot and needs to be micro optimised
            hash = {}

            index = 0
            length = columns.length

            while index < length
              hash[columns[index]] = row[index]
              index += 1
            end

            hash
          }
        end
  end
end