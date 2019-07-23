class CreateRolify::V20190626181723 < Avram::Migrator::Migration::V1
  def migrate
    create :roles do
      primary_key id : Int64
      add_timestamps

      add name : String
      add resource_type : String?
      add resource_id : Int64?
      add description : String?
    end

    create :users_roles do
      primary_key id : Int64
      add_timestamps

      add_belongs_to user : User, on_delete: :cascade
      add_belongs_to role : Role, on_delete: :cascade
    end

    execute "CREATE INDEX index_roles_on_name ON public.roles USING btree (name);"
    execute "CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON public.roles USING btree (name, resource_type, resource_id);"
    execute "CREATE INDEX index_roles_on_resource_type_and_resource_id ON public.roles USING btree (resource_type, resource_id);"
  end

  def rollback
    execute "DROP INDEX index_roles_on_resource_type_and_resource_id;"
    execute "DROP INDEX index_roles_on_name_and_resource_type_and_resource_id;"
    execute "DROP INDEX index_roles_on_name;"

    drop :users_roles
    drop :roles
  end
end
