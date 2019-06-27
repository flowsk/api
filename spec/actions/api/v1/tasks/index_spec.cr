require "../../../../spec_helper"

include ContextHelper

describe "Api::V1::Tasks::Index" do
  it "returns an empty json response" do
    user = UserBox.create
    response = Api::V1::Tasks::Index.new(build_context(user: user), params).call
    JSON.parse(response.body).should eq({"tasks" => [] of Task})
  end

  it "returns all tasks" do
    user = UserBox.create
    tasklist = TasklistBox.create &.user_id(user.id)
    task1 = TaskBox.create &.tasklist_id(tasklist.id)
    task2 = TaskBox.create &.tasklist_id(tasklist.id)

    response = Api::V1::Tasks::Index.new(build_context(user: user), params).call
    tasks = JSON.parse(response.body)["tasks"]
    tasks[0]["id"].should eq(task1.cuid)
    tasks[1]["id"].should eq(task2.cuid)
  end
end
