class TasklistBox < Avram::Box
  def initialize
    cuid Cuid.generate
    user_id UserBox.create.id
  end
end
