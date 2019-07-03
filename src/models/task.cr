require "./tasklist.cr"

class Task < BaseModel
  table :tasks do
    column cuid : String
    column title : String
    column completed : Bool?
    column started_at : Time?
    column due_at : Time?
    column completed_at : Time?
    belongs_to tasklist : Tasklist
  end

  def roles
    RoleQuery.new.resource_type(self.class.to_s).resource_id(self.id)
  end

  def applied_roles
    RoleQuery.new.applied_roles(resource: self)
  end

  def self.with_role(role : Symbol)
    users_roles = UserRoleQuery.new.preload_role.join_roles.roles { |user_role|
      user_role.resource_type("Task").name(role.to_s)
    }
    roles_ids = users_roles.map { |x| x.role.resource_id }.compact

    TaskQuery.new.find_in(ids: roles_ids)
  end

  def self.with_role(role : Symbol, user : User)
    users_roles = UserRoleQuery.new.user_id(user.id).preload_role.join_roles.roles { |user_role|
      user_role.resource_type("Task").name(role.to_s)
    }
    roles_ids = users_roles.map { |x| x.role.resource_id }.compact
    roles_ids_sql = roles_ids.to_s.sub("[", "(").sub("]", ")")
    TaskQuery.new.find_in(ids: roles_ids)
  end

  def self.with_role(role : Array(Symbol), user : User)
    role = role.map(&.to_s)
    roles_sql = role.to_s.sub("[", "(").sub("]", ")").gsub("\"", "'")
    users_roles = UserRoleQuery.new.user_id(user.id).preload_role.join_roles.roles { |user_role|
      user_role.resource_type("Task").where("name IN #{roles_sql}")
    }
    roles_ids = users_roles.map { |x| x.role.resource_id }.compact
    roles_ids_sql = roles_ids.to_s.sub("[", "(").sub("]", ")")
    TaskQuery.new.find_in(ids: roles_ids)
  end

  def self.without_role(role : Symbol)
    users_roles = UserRoleQuery.new.preload_role.join_roles.roles { |user_role|
      user_role.resource_type("Task").name(role.to_s)
    }
    roles_ids = users_roles.map { |x| x.role.resource_id }.compact
    TaskQuery.new.find_not_in(ids: roles_ids)
  end
end
