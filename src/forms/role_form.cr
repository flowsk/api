class RoleForm < Role::SaveOperation
  permit_columns name
end
