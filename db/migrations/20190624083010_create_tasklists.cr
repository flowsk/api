class CreateTasklists::V20190624083010 < Avram::Migrator::Migration::V1
  def migrate
    create :tasklists do
      add cuid : String, unique: true
      add_belongs_to user : User, on_delete: :cascade
    end
  end

  def rollback
    drop :tasklists
  end
end
