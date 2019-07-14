require "../spec_helper.cr"
require "wordsmith"

class LengthValidator < Legit::BaseValidator
  def validate
    return true if options.is_a?(Bool)
    if has_option?(:minimum) && value.is_a?(String)
      @errors.add(attribute, "is too short (minimum is #{options[:minimum]} characters)") if value.size < options[:minimum]
    end
  end
end

describe "Legit::Validator" do
  it "single validaton" do
    validator = LengthValidator.new("name", Legit::Errors.new, true, "name")
    validator.has_option?(:foo).should be_falsey
  end
end
