class Api::V1::Pomodoros::Create < Api::V1::AuthenticatedAction
  route do
    task_id = params.nested("pomodoro").get("task_id")
    if task_id
      task = TaskQuery.find(task_id)
      Tasklist.with_role(:owner, current_user).id(task.tasklist_id).first
    end

    CreateForm.create(params, current_user: current_user) do |form, pomodoro|
      if pomodoro
        json ShowSerializer.new(pomodoro)
      else
        json Errors::ShowSerializer.new("Could not save pomodoro", details: form.errors.join(", "))
      end
    end
  end
end
