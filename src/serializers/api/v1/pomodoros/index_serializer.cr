require "./show_serializer"

class Api::V1::Pomodoros::IndexSerializer < Lucky::Serializer
  def initialize(@pomodoros : PomodoroQuery)
  end

  def render
    {
      pomodoros: @pomodoros.map { |pomodoro| ShowSerializer.new(pomodoro) },
      # total: @tasks.count,
    }
  end
end
