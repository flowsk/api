class User < BaseModel
  include Carbon::Emailable
  include Authentic::PasswordAuthenticatable

  table :users do
    column name : String
    column email : String
    column encrypted_password : String
    has_many tasklists : Tasklist
    has_many tasks : Task, through: :tasklists

    has_many users_roles : UserRole
    has_many roles : Role, through: :users_roles
  end

  def emailable
    Carbon::Address.new(email)
  end

  def add_role(role : Symbol)
    # Create Role
    db_role = RoleQuery.new.name(role.to_s).first?
    db_role = RoleForm.create!(name: role.to_s) unless db_role

    find_or_create_user_role(role: db_role)
  end

  def remove_role(role : Symbol)
    roles = UserRoleQuery.new.user_id(self.id).join_roles.where_roles { |user_role|
      user_role.name(role.to_s)
    }
    remove_roles(roles)
    true
  end

  def add_role(role : Symbol, resource : Avram::Model)
    # Create Role
    db_role = RoleQuery.new.name(role.to_s).resource_type(resource.class.to_s).resource_id(resource.id).first?
    db_role = RoleForm.create!(name: role.to_s, resource_type: resource.class.to_s, resource_id: resource.id) unless db_role

    find_or_create_user_role(role: db_role)
  end

  def remove_role(role : Symbol, resource : Avram::Model)
    roles = UserRoleQuery.new.user_id(self.id).join_roles.where_roles { |user_role|
      user_role.name(role.to_s).resource_type(resource.class.to_s).resource_id(resource.id)
    }
    remove_roles(roles)
    true
  end

  def add_role(role : Symbol, resource : Avram::Model.class)
    # Create Role
    db_role = RoleQuery.new.name(role.to_s).resource_type(resource.to_s).first?
    db_role = RoleForm.create!(name: role.to_s, resource_type: resource.to_s) unless db_role

    find_or_create_user_role(role: db_role)
  end

  def remove_role(role : Symbol, resource : Avram::Model.class)
    roles = UserRoleQuery.new.user_id(self.id).join_roles.where_roles { |user_role|
      user_role.name(role.to_s).resource_type(resource.to_s)
    }
    remove_roles(roles)
    true
  end

  def has_role?(role : Symbol)
    role = RoleQuery.new.name(role.to_s).first
    check_user_role!(role: role)
    true
  rescue Avram::RecordNotFoundError
    false
  end

  def has_role?(role : Symbol, resource : Avram::Model)
    # Check role for resource class
    return true if has_role?(role: role, resource: resource.class)

    # Else check for instance
    role = RoleQuery.new.name(role.to_s).resource_type(resource.class.to_s).resource_id(resource.id).first
    check_user_role!(role: role)
    true
  rescue Avram::RecordNotFoundError
    false
  end

  def has_strict_role?(role : Symbol, resource : Avram::Model)
    # Else check for instance
    role = RoleQuery.new.name(role.to_s).resource_type(resource.class.to_s).resource_id(resource.id).first
    check_user_role!(role: role)
    true
  rescue Avram::RecordNotFoundError
    false
  end

  def has_role?(role : Symbol, resource : Avram::Model.class)
    role = RoleQuery.new.name(role.to_s).resource_type(resource.to_s).resource_id.nilable_eq(nil).first
    check_user_role!(role: role)
    true
  rescue Avram::RecordNotFoundError
    false
  end

  private def check_user_role!(role : Role)
    RoleQuery.new.join_users_roles.where_users_roles { |user_role|
      user_role.user_id(self.id).role_id(role.id)
    }.first
  end

  private def find_or_create_user_role(role : Role)
    user_role = RoleQuery.new.join_users_roles.where_users_roles { |user_role|
      user_role.user_id(self.id).role_id(role.id)
    }.first
  rescue Avram::RecordNotFoundError
    UserRoleForm.create!(user_id: self.id, role_id: role.id)
  end

  private def remove_roles(roles : UserRoleQuery)
    roles_ids = roles.map &.id
    return true if roles_ids.empty?
    roles_ids_sql = roles_ids.to_s.sub("[", "(").sub("]", ")")
    sql = <<-SQL
      DELETE FROM users_roles WHERE id = #{roles_ids_sql}
    SQL
    AppDatabase.run do |db|
      db.query_all sql, as: Role
    end
  end
end
