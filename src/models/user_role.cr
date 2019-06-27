class UserRole < BaseModel
  table :users_roles do
    belongs_to user : User
    belongs_to role : Role
  end
end
