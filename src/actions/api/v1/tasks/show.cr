class Api::V1::Tasks::Show < Api::V1::AuthenticatedAction
  route do
    task = TaskQuery.new.cuid(params.get("task_id")).limit(1).first
    json ShowSerializer.new(task)
  end
end
