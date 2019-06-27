class TaskBox < Avram::Box
  def initialize
    cuid Cuid.generate
    title "Task 1"
    completed false
    tasklist_id TasklistBox.create.id
  end
end
