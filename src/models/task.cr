require "./tasklist.cr"

class Task < BaseModel
  table :tasks do
    column cuid : String
    column title : String
    column completed : Bool?
    column started_at : Time?
    column due_at : Time?
    column completed_at : Time?
    belongs_to tasklist : Tasklist
  end
end
