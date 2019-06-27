class Api::V1::Tasks::Index < Api::V1::AuthenticatedAction # changed this
  route do
    tasks = TaskQuery.all
    json IndexSerializer.new(tasks)
  end
end
