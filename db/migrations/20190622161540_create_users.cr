class CreateUsers::V20190622161540 < Avram::Migrator::Migration::V1
  def migrate
    create :users do
      add name : String
      add email : String, unique: true
      add encrypted_password : String
    end
  end

  def rollback
    drop :users
  end
end
