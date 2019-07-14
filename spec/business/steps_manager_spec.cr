require "../spec_helper.cr"

private class StepManager < Business::Operation
  step :one
  step :two, StepTwo

  define_step :one, ->(ctx : Context, params : Params) {
    ctx["sum"] = params["initial"].as(Int32) + 4
    true
  }

  class StepTwo < Business::Step
    def run(ctx : Context, params : Business::Types)
      ctx["final"] = ctx["sum"].as(Int32) + 6
      true
    end
  end
end

describe Business::StepsManager do
  it "add step" do
  end
end
