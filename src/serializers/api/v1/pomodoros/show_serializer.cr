class Api::V1::Pomodoros::ShowSerializer < Lucky::Serializer
  def initialize(@pomodoro : Pomodoro)
  end

  def render
    started_at = nil
    if started_at = @pomodoro.started_at
      started_at = started_at.to_s("%Y-%m-%d %H:%M:%S %z")
    end

    finished_at = nil
    if finished_at = @pomodoro.finished_at
      finished_at = finished_at.to_s("%Y-%m-%d %H:%M:%S %z")
    end
    {
      id:          @pomodoro.cuid,
      started_at:  started_at,
      finished_at: finished_at,
      status:      @pomodoro.status,
      task_id:     @pomodoro.task_id,
    }
  end
end
