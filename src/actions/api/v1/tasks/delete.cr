class Api::V1::Tasks::Delete < ApiAction
  route do
    TaskQuery.new.cuid(params.get("task_id")).limit(1).first.delete
    head HTTP::Status::NO_CONTENT
  end
end
