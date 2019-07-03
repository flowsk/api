require "../../../../../spec_helper"

include ContextHelper

private def post_params
  {} of String => String
end

private def execute_action(params, id : Int32, user : User)
  context = post(user: user, params: params)
  response = Api::V1::Pomodoros::Finish::Create.new(context, {"pomodoro_id" => id.to_s}).call
end

describe Api::V1::Pomodoros::Finish::Create do
  describe "security" do
    it "cant create for other task" do
      user = UserBox.create
      task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
      pomodoro = Api::V1::Pomodoros::CreateForm.create!(current_user: user, task_id: task.id)

      guest = UserBox.create

      expect_raises(Avram::RecordNotFoundError, "Could not find first record in tasklists") do
        response = execute_action(post_params, id: pomodoro.id, user: guest)
      end
    end
  end

  it "finishes a record" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
    pomodoro = Api::V1::Pomodoros::CreateForm.create!(current_user: user, task_id: task.id)

    response = execute_action(post_params, id: pomodoro.id, user: user)
    json = JSON.parse(response.body)

    json["id"].should eq(pomodoro.cuid)
    json["status"].should eq("finished")
    time = Time.parse(json["started_at"].as_s, "%Y-%m-%d %H:%M:%S %z", Time::Location::UTC)
    (Time.utc.to_unix - time.to_unix).should be < 2
  end

  it "does not update finished at for an already finished record" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
    pomodoro = Api::V1::Pomodoros::CreateForm.create!(current_user: user, task_id: task.id)

    response = execute_action(post_params, id: pomodoro.id, user: user)
    json = JSON.parse(response.body)
    first_time = Time.parse(json["finished_at"].as_s, "%Y-%m-%d %H:%M:%S %z", Time::Location::UTC)

    Timecop.freeze(5.hours.from_now) do
      response = execute_action(post_params, id: pomodoro.id, user: user)
      json = JSON.parse(response.body)
      second_time = Time.parse(json["finished_at"].as_s, "%Y-%m-%d %H:%M:%S %z", Time::Location::UTC)
      (second_time.to_unix - first_time.to_unix).should be < 2
    end
  end
end
