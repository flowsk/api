module Legit
  class Errors
    getter errors

    def initialize
      @errors = {} of String => Array(String)
    end

    def add(attribute : String, error)
      @errors[attribute] = [] of String unless @errors.has_key?(attribute)
      @errors[attribute] << error
    end

    def [](attribute : String)
      @errors[attribute]
    end

    def empty?
      @errors.empty?
    end
  end
end
