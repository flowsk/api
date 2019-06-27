require "./show_serializer"

class Api::V1::Tasks::IndexSerializer < Lucky::Serializer
  def initialize(@tasks : TaskQuery)
  end

  def render
    {
      tasks: @tasks.map { |task| ShowSerializer.new(task) },
      # total: @tasks.count,
    }
  end
end
