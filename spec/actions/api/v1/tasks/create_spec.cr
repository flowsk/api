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

private def execute_action(params, user : User)
  context = post(user: user, params: params)
  response = Api::V1::Tasks::Create.new(context, {} of String => String).call
end

describe Api::V1::Tasks::Create do
  describe "security" do
    it "add owner role to tasklist" do
      post_params = params
      user = UserBox.create

      response = execute_action(post_params, user: user)

      json = JSON.parse(response.body)
      task_id = json["id"].as_s
      tasklist = TaskQuery.new.cuid(task_id).preload_tasklist.first.tasklist
      user.has_role?(:owner, tasklist).should be_truthy
    end
  end

  it "creates a record" do
    post_params = params
    user = UserBox.create

    response = execute_action(post_params, user: user)

    json = JSON.parse(response.body)
    json["id"].should eq(post_params["task"]["id"])
    json["completed"].should eq(false)
  end

  it "acceptes completed value" do
    post_params = params({"completed" => "true"})
    post_params["task"].delete("id")
    user = UserBox.create

    response = execute_action(post_params, user: user)

    json = JSON.parse(response.body)
    Cuid.validate(json["id"].to_s).should be_truthy
    json["completed"].should eq(true)
  end

  it "creates a tasklist then reuse it" do
    post_params = params
    post_params["task"].delete("id")
    user = UserBox.create

    # Create First Task
    response = execute_action(post_params, user: user)
    tasklist = TasklistQuery.new.user_id(user.id).first
    TasklistQuery.new.user_id(user.id).size.should eq(1)
    TaskQuery.new.tasklist_id(tasklist.id).size.should eq(1)

    # Create Second Task
    response = execute_action(post_params, user: user)
    tasklist = TasklistQuery.new.user_id(user.id).first
    TasklistQuery.new.user_id(user.id).size.should eq(1)
    TaskQuery.new.tasklist_id(tasklist.id).size.should eq(2)
  end
end
