require "../../../../spec_helper"

include ContextHelper

private def execute_action(id, user : User)
  context = get(user: user, params: {} of String => String)
  response = Api::V1::Tasks::Show.new(context, {"task_id" => id.to_s}).call
end

describe "Api::V1::Tasks::Show" do
  it "shows a record" do
    user = UserBox.create
    task = TaskBox.create

    response = execute_action(task.cuid, user: user)

    json = JSON.parse(response.body)
    json["id"].should eq(task.cuid)
  end
end
