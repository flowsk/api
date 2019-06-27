require "./spec_helper"

describe Cuid do
  it "test_generate_string" do
    c = Cuid.generate
    c.class.should eq(String)

    c = Cuid.generate
    c.class.should eq(String)
  end

  it "test_generate_array" do
    c = Cuid.generate_many(3)
    array_type = Array(String).to_s
    c.class.to_s.should eq(array_type)
    c.size.should eq(3)
  end

  it "test_generate_format" do
    c = Cuid.generate
    c.size.should eq(25)
    c.starts_with?("c").should eq(true)
  end

  it "test_validate_true" do
    c = Cuid.generate
    Cuid.validate(c).should be_truthy
  end

  it "test_validate_false" do
    c = "d00000000000000000000"
    Cuid.validate(c).should be_falsey
  end

  it "test_collision" do
    results = {} of String => Bool
    collision = false
    c = Cuid.generate_many(600_000)
    c.each do |e|
      collision = true if results.has_key?(e)
      results[e] = true
    end
    collision.should be_falsey
  end

  it "test_secure_random" do
    Cuid.generate
    results = {} of String => Bool
    collision = false
    c = Cuid.generate_many(1000)
    c.each do |e|
      collision = true if results.has_key?(e)
      results[e] = true
    end
    collision.should be_falsey
  end
end
