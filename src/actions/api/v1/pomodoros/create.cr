class Api::V1::Pomodoros::Create < Api::V1::AuthenticatedAction
  route do
    task_id = params.nested("pomodoro").get("task_id")
    if task_id
      task = TaskQuery.new.cuid(task_id).limit(1).first
      Tasklist.with_role(:owner, current_user).id(task.tasklist_id).first
      CreateForm.create(params, task: task, current_user: current_user) do |form, pomodoro|
        if pomodoro
          json ShowSerializer.new(pomodoro)
        else
          json Errors::ShowSerializer.new("Could not save pomodoro", details: form.errors.join(", "))
        end
      end
    else
      raise UnauthorizedError.new("You dont have access")
    end
  end
end
