class Api::V1::Tasks::ShowSerializer < Lucky::Serializer
  def initialize(@task : Task)
  end

  def render
    {
      id:           @task.cuid,
      title:        @task.title,
      completed:    @task.completed,
      started_at:   @task.started_at,
      due_at:       @task.due_at,
      completed_at: @task.completed_at,
    }
  end
end
