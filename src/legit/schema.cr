require "./validator"

module Legit
  class PresenceValidator < BaseValidator
    def validate
      errors.add("name", "can't be blank") if value.nil?
    end
  end

  class LengthValidator < BaseValidator
    def validate
      if has_option?(:minimum)
        test_value = value
        if test_value.is_a?(String)
          errors.add(attribute, "is too short (minimum is #{options[:minimum]} characters)") if test_value.size < options[:minimum]
        end
      end
    end
  end

  class Schema(T)
    getter :subject
    getter :errors
    class_getter validators : Array(Validator) = [] of Validator

    macro validates(attribute, **rules)
      def validate
      {% if @type.has_method?(:validate) %}
        previous_def
      {% end %}
      {% for rule in rules.keys %}      
        {% if rules[rule].is_a?(BoolLiteral) %}
        Legit::{{run("./run_macros/camelize.cr", rule.id)}}Validator.new(
          {{attribute.stringify}}, errors, {{rules[rule]}}, subject.{{attribute}}
        ).validate
        {% else %}
        Legit::{{run("./run_macros/camelize.cr", rule.id)}}Validator.new(
          {{attribute.stringify}}, errors, {{rules[rule]}}.to_h, subject.{{attribute}}
        ).validate
        {% end %}
      {% end %}
      end
    end

    macro validates_with(validator, options = {} of Symbol => Int32)
      def validate
        {% if @type.has_method?("validate") %}
          previous_def
        {% end %}
        {{validator}}.new(errors).validate(subject)
      end
    end

    def self.validate(subject)
      new(subject)
    end

    def initialize(@subject : T)
      @errors = Errors.new
      validate
    end

    def valid?
      return true if @errors.empty?
      false
    end
  end
end
