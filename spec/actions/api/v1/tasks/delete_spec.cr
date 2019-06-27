require "../../../../spec_helper"

include ContextHelper

private def execute_action(id, user : User)
  context = delete(user: user, params: {} of String => String)
  response = Api::V1::Tasks::Delete.new(context, {"task_id" => id}).call
end

describe "Api::V1::Tasks::Delete" do
  it "deletes a record" do
    user = UserBox.create
    task = TaskBox.create

    response = execute_action(task.cuid, user: user)

    expect_raises(Avram::RecordNotFoundError, "Could not find tasks with id of #{task.id}") do
      TaskQuery.find(task.id)
    end
  end
end
