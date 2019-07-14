require "../spec_helper.cr"
require "wordsmith"

class Person
  JSON.mapping(
    name: String?,
  )
end

class MyValidator < Legit::Validator
  def validate(record)
    if name = record.name
      unless name.starts_with? 'C'
        errors.add("name", "Need a name starting with C please!")
      end
    end
  end
end

class Schema(T) < Legit::Schema(T)
  validates name, presence: true, length: {minimum: 2}
  validates_with MyValidator
end

describe "Legit" do
  describe "single validaton" do
    it "validates" do
      person = Person.from_json({"name" => "Celso"}.to_json)
      result = Schema(Person).validate(person)
      result.valid?.should be_truthy
    end

    it "invalidates missing name" do
      person = Person.from_json({"name" => nil}.to_json)
      result = Schema(Person).validate(person)
      result.valid?.should be_falsey
    end
  end

  describe "errors" do
    it "show errors for the name" do
      person = Person.from_json({"name" => "B"}.to_json)
      result = Schema(Person).validate(person)
      result.valid?.should be_falsey
      result.errors["name"].should eq([
        "is too short (minimum is 2 characters)",
        "Need a name starting with C please!",
      ])
    end
  end

  describe "custom validation" do
    it "validates using custom validator" do
      person = Person.from_json({"name" => "Belso"}.to_json)
      result = Schema(Person).validate(person)
      result.valid?.should be_falsey
    end
  end
end
