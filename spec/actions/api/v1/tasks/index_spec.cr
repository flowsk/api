require "../../../../spec_helper"

include ContextHelper

describe Api::V1::Tasks::Index do
  describe "security" do
    it "#security only show users tasks" do
      user = UserBox.create
      task1 = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")

      guest = UserBox.create
      guest_task1 = Api::V1::Tasks::CreateForm.create!(current_user: guest, title: "Guest First Task")

      response = Api::V1::Tasks::Index.new(build_context(user: user), params).call
      tasks = JSON.parse(response.body)["tasks"]
      tasks.size.should eq(1)
      tasks[0]["id"].should eq(task1.cuid)
    end
  end

  it "returns an empty json response" do
    user = UserBox.create
    response = Api::V1::Tasks::Index.new(build_context(user: user), params).call
    JSON.parse(response.body).should eq({"tasks" => [] of Task})
  end

  it "returns all tasks" do
    user = UserBox.create
    task1 = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
    task2 = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User Second Task")

    response = Api::V1::Tasks::Index.new(build_context(user: user), params).call
    tasks = JSON.parse(response.body)["tasks"]
    tasks.size.should eq(2)
    tasks_ids = [tasks[0]["id"], tasks[1]["id"]]

    tasks_ids.should contain(task1.cuid)
    tasks_ids.should contain(task2.cuid)
  end
end
