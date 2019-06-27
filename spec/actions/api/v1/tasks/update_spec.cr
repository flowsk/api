require "../../../../spec_helper"

include ContextHelper

private def params(merged = {} of String => String)
  {
    "task" => {
      "id"    => Cuid.generate,
      "title" => "This is my first task",
    }.merge!(merged),
  }
end

private def execute_action(params, id : String, user : User)
  context = post(user: user, params: params)
  response = Api::V1::Tasks::Update.new(context, {"task_id" => id}).call
end

describe "Api::V1::Tasks::Update" do
  it "creates a record" do
    post_params = params
    post_params["task"]["completed"] = "true"
    post_params["task"]["title"] = "New Title"
    user = UserBox.create
    task = TaskBox.create
    count = TaskQuery.new.select_count

    response = execute_action(post_params, id: task.cuid, user: user)

    TaskQuery.new.select_count.should eq(count)
    json = JSON.parse(response.body)
    json["id"].should eq(post_params["task"]["id"])
    json["completed"].should eq(true)
    json["title"].should eq("New Title")
  end
end
