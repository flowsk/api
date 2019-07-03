class PomodoroBox < Avram::Box
  def initialize
    cuid Cuid.generate
    status "running"
    started_at Time.utc
  end
end
