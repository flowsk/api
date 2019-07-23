class SignUpForm < User::SaveOperation
  include PasswordValidations
  before_save :prepare

  param_key :sign_up

  permit_columns name
  permit_columns email
  attribute password : String
  attribute password_confirmation : String

  def prepare
    validate_uniqueness_of email
    run_password_validations
    Authentic.copy_and_encrypt password, to: encrypted_password
  end
end
