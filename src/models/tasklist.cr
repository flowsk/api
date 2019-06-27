require "./user.cr"

class Tasklist < BaseModel
  table :tasklists do
    column cuid : String
    belongs_to user : User
    has_many tasks : Task
  end
end
