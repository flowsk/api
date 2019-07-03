class CreatePomodoro::V20190702145005 < Avram::Migrator::Migration::V1
  def migrate
    create :pomodoros do
      add cuid : String, unique: true
      add started_at : Time?
      add finished_at : Time?
      add status : String?
      add_belongs_to task : Task, on_delete: :cascade
    end
  end

  def rollback
    drop :pomodoros
  end
end
