class Api::V1::Tasks::Index < Api::V1::AuthenticatedAction # changed this
  route do
    tasklist = Tasklist.with_role(:owner, current_user).limit(1).first?
    if tasklist
      tasks = TaskQuery.new.tasklist_id(tasklist.id)
      json IndexSerializer.new(tasks)
    else
      json IndexSerializer.new(TaskQuery.new.none)
    end
  end
end
