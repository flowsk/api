class Role < BaseModel
  table :roles do
    column name : String
    column resource_type : String?
    column resource_id : Int32?

    has_many users_roles : UserRole
    has_many users : User, through: :users_roles
  end
end
