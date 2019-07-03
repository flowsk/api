require "./task.cr"

class Pomodoro < BaseModel
  table :pomodoros do
    column cuid : String
    column started_at : Time?
    column finished_at : Time?
    column status : String?
    belongs_to task : Task
  end
end
