module Legit
  class BaseValidator
    getter errors
    getter value : String?
    getter options : Hash(Symbol, Int32) = Hash(Symbol, Int32).new
    getter attribute : String

    def initialize(@attribute : String, @errors : Errors, options : Bool, @value)
      @options = {} of Symbol => Int32
    end

    def initialize(@attribute : String, @errors : Errors, @options : Hash(Symbol, Int32), @value)
      @options = options.to_h
    end

    def initialize(@attribute : String, @errors : Errors, @options : Int32)
    end

    def has_option?(option)
      return true if options.has_key?(option)
      false
    end
  end

  abstract class Validator
    getter errors

    def initialize(@errors : Errors)
    end

    def validate
    end
  end
end
