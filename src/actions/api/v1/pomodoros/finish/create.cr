class Api::V1::Pomodoros::Finish::Create < Api::V1::AuthenticatedAction
  nested_route do
    pomodoro_id = params.get("pomodoro_id") || 0
    pomodoro = PomodoroQuery.find(pomodoro_id)
    task = TaskQuery.find(pomodoro.task_id)
    Tasklist.with_role(:owner, current_user).id(task.tasklist_id).first

    return json Api::V1::Pomodoros::ShowSerializer.new(pomodoro) if pomodoro.status == "finished"

    CreateForm.update(pomodoro, {"pomodoro" => ""}, current_user: current_user) do |form, pomodoro|
      if pomodoro
        json Api::V1::Pomodoros::ShowSerializer.new(pomodoro)
      else
        json Errors::ShowSerializer.new("Could not unpause pomodoro", details: form.errors.join(", "))
      end
    end
  end
end
