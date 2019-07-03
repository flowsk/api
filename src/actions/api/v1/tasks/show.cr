class Api::V1::Tasks::Show < Api::V1::AuthenticatedAction
  route do
    tasklist = Tasklist.with_role(:owner, current_user).limit(1).first?

    if tasklist
      task = TaskQuery.new.cuid(params.get("task_id")).tasklist_id(tasklist.id).limit(1).first
      json ShowSerializer.new(task)
    else
      raise UnauthorizedError.new("You dont have access")
    end
  end
end
