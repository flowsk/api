require "../../../../spec_helper"

include ContextHelper

private def params(merged = {} of String => String)
  {
    "pomodoro" => {
      "id" => Cuid.generate,
    }.merge!(merged),
  }
end

private def execute_action(params, user : User)
  context = post(user: user, params: params)
  response = Api::V1::Pomodoros::Create.new(context, {} of String => String).call
end

describe Api::V1::Pomodoros::Create do
  describe "security" do
    it "cant create for other task" do
      user = UserBox.create
      task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")

      guest = UserBox.create
      post_params = params({"task_id" => task.cuid})

      expect_raises(Avram::RecordNotFoundError, "Could not find first record in tasklists") do
        response = execute_action(post_params, user: guest)
      end
    end
  end

  it "creates a record" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
    post_params = params({"task_id" => task.cuid})

    response = execute_action(post_params, user: user)

    json = JSON.parse(response.body)
    json["id"].should eq(post_params["pomodoro"]["id"])
    json["status"].should eq("running")
    time = Time.parse(json["started_at"].as_s, "%Y-%m-%d %H:%M:%S %z", Time::Location::UTC)
    (Time.utc.to_unix - time.to_unix).should be < 2
  end

  it "do not accepts a status value" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
    post_params = params({"status" => "finished", "task_id" => task.cuid})
    post_params["pomodoro"].delete("id")

    response = execute_action(post_params, user: user)

    json = JSON.parse(response.body)
    Cuid.validate(json["id"].to_s).should be_truthy
    json["status"].should eq("running")
  end
end
