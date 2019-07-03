require "../../../../../spec_helper"

include ContextHelper

private def post_params
  {} of String => String
end

private def execute_action(params, id : Int32, user : User)
  context = post(user: user, params: params)
  response = Api::V1::Pomodoros::Pause::Create.new(context, {"pomodoro_id" => id.to_s}).call
end

describe Api::V1::Pomodoros::Pause::Create do
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

  it "pauses a record" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
    pomodoro = Api::V1::Pomodoros::CreateForm.create!(current_user: user, task_id: task.id)

    response = execute_action(post_params, id: pomodoro.id, user: user)
    json = JSON.parse(response.body)

    json["id"].should eq(pomodoro.cuid)
    json["status"].should eq("paused")
  end

  it "can not pause a finished record" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")
    pomodoro = PomodoroBox.create &.task_id(task.id).status("finished")

    response = execute_action(post_params, id: pomodoro.id, user: user)
    json = JSON.parse(response.body)

    json["id"].should eq(pomodoro.cuid)
    json["status"].should eq("finished")
  end
end
