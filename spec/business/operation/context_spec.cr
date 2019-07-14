require "../../spec_helper.cr"

describe Business::Operation::Context do
  it "accepts and returns data" do
    ctx = Business::Operation::Context.new
    (ctx["sum"] = 2).should eq(2)
    ctx["sum"].should eq(2)
  end

  it "raises and error when mutating data" do
    ctx = Business::Operation::Context.new
    (ctx["sum"] = 2).should eq(2)

    expect_raises Business::Operation::Context::MutateDataException, "Do not change existing sum key" do
      ctx["sum"] = 2
    end
  end
end
