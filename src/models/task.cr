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
    roles_ids = users_roles.map { |x| x.role.resource_id }
    roles_ids.compact
    roles_ids_sql = roles_ids.to_s.sub("[", "(").sub("]", ")")
    TaskQuery.new.where("id IN #{roles_ids_sql}")
  end

  def self.without_role(role : Symbol)
    users_roles = UserRoleQuery.new.preload_role.join_roles.roles { |user_role|
      user_role.resource_type("Task").name(role.to_s)
    }
    roles_ids = users_roles.map { |x| x.role.resource_id }
    roles_ids.compact
    if roles_ids.empty?
      TaskQuery.all
    else
      roles_ids_sql = roles_ids.to_s.sub("[", "(").sub("]", ")")
      TaskQuery.new.where("id NOT IN #{roles_ids_sql}")
    end
  end
end
