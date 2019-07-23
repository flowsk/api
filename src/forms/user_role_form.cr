class UserRoleForm < UserRole::SaveOperation
  permit_columns user_id
  permit_columns role_id
end
