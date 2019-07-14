require "../spec_helper.cr"

class Foo
  getter name

  def initialize(@name : String)
  end
end

alias CustomTypes = Business::Types | Foo

module Business
  define_type(CustomTypes)
end

# ################# DUMMY
class Dummy < Business::Operation
  step :one
  step :two

  define_step :one, ->(ctx : Context, params : Params) {
    ctx["sum"] = params["initial"].as(Int32) + 4
    true
  }

  define_step :two, ->(ctx : Context, params : Params) {
    ctx["final"] = ctx["sum"].as(Int32) + 6
    true
  }
end

# ################# DUMMY 2
class Dummy2 < Business::Operation
  step :one, StepOne
  step :two, StepTwo

  class StepOne < Business::Step
    def run(ctx : Context, params : Params)
      ctx["sum"] = params["initial"].as(Int32) + 4
      true
    end
  end

  class StepTwo < Business::Step
    def run(ctx : Context, params : Params)
      ctx["final"] = ctx["sum"].as(Int32) + 6
      true
    end
  end
end

# ################# DUMMY 3
class Dummy3 < Business::Operation
  step :one
  step :two, StepTwo

  define_step :one, ->(ctx : Context, params : Params) {
    ctx["sum"] = params["initial"].as(Int32) + 4
    true
  }

  class StepTwo < Business::Step
    def run(ctx : Context, params : Params)
      ctx["final"] = ctx["sum"].as(Int32) + 6
      true
    end
  end
end

class FailOperation < Business::Operation
  step :one
  failure :fail
  step :two

  define_step :one, ->(ctx : Context, params : Params) {
    false
  }

  define_step :fail, ->(ctx : Context, params : Params) {
    ctx["final"] = "error logged"
    true
  }

  define_step :two, ->(ctx : Context, params : Params) {
    ctx["two"] = true
    true
  }
end

class OtherContext < Business::Operation
  step :one

  define_step :one, ->(ctx : Context, params : Params) {
    ctx["model"] = Foo.new("fooooo")
    true
  }

  define_step :fail, ->(ctx : Context, params : Params) {
    ctx["final"] = "error logged"
    true
  }

  define_step :two, ->(ctx : Context, params : Params) {
    ctx["two"] = true
    true
  }
end

describe Business::Operation do
  it "dummy goes" do
    params = Business::Operation::Params.new
    params["initial"] = 1
    res = Dummy.run(params: params)
    res.success?.should eq(true)
    res["final"].should eq(11)
  end

  it "dummy2 goes" do
    params = Business::Operation::Params.new
    params["initial"] = 1
    res = Dummy2.run(params: params)
    res.success?.should eq(true)
    res["final"].should eq(11)
  end

  it "dummy3 goes" do
    params = Business::Operation::Params.new
    params["initial"] = 1
    res = Dummy3.run(params: params)
    res.success?.should eq(true)
    res["final"].should eq(11)
  end

  it "fail goes to failure step" do
    params = Business::Operation::Params.new
    res = FailOperation.run(params: params)
    res.success?.should be_falsey
    res["final"].should eq("error logged")
    expect_raises KeyError, "Missing hash key: \"two\"" do
      res["two"].should be_nil
    end
  end

  it "putting other elements on context" do
    params = Business::Operation::Params.new
    res = OtherContext.run(params: params)
    res.success?.should be_truthy
  end
end
