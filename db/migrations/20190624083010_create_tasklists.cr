class CreateTasklists::V20190624083010 < Avram::Migrator::Migration::V1
  def migrate
    create :tasklists do
      primary_key id : Int64
      add_timestamps
      add cuid : String, unique: true
      add deleted_at : Time?
      add_belongs_to user : User, on_delete: :cascade
    end

    create_index :tasklists, [:cuid, :deleted_at], unique: false
  end

  def rollback
    drop :tasklists
  end
end
