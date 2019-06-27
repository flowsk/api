class Api::V1::Tasks::Update < Api::V1::AuthenticatedAction
  route do
    task = TaskQuery.new.cuid(params.get("task_id")).limit(1).first
    CreateForm.update(task, params, current_user: current_user) do |form, task|
      if task
        json ShowSerializer.new(task)
      else
        json Errors::ShowSerializer.new("Could not save task", details: form.errors.join(", "))
      end
    end
  end
end
