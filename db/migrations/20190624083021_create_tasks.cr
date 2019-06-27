class CreateTasks::V20190624083021 < Avram::Migrator::Migration::V1
  def migrate
    create :tasks do
      add cuid : String, unique: true
      add title : String
      add completed : Bool
      add started_at : Time?
      add due_at : Time?
      add completed_at : Time?
      add_belongs_to tasklist : Tasklist, on_delete: :cascade
    end
  end

  def rollback
    drop :tasks
  end
end
