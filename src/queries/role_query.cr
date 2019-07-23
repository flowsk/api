class RoleQuery < Role::BaseQuery
  def applied_roles(resource : Avram::Model)
    resource_class = resource.class.to_s
    resource_id = resource.id
    sql = <<-SQL
      SELECT roles.id, roles.created_at, roles.updated_at, roles.name, roles.resource_type, roles.resource_id
      FROM roles
      WHERE (
        roles.resource_type = '#{resource_class}' AND roles.resource_id = '#{resource_id}'
      ) OR (
        roles.resource_type = '#{resource_class}' AND roles.resource_id IS NULL
      )
    SQL
    AppDatabase.run do |db|
      db.query_all sql, as: Role
    end
  end
end
