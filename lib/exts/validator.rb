module ActiveModel
  class Validator
    alias_method :super_initialize, :initialize
    def initialize(options={})
      if options[:strict].nil?
        options[:strict] = ConflictAnalysis.options[:strict]
      end
      super_initialize(options)
    end
  end
end