class SignUpForm < User::BaseForm
  include PasswordValidations

  fillable name, email
  virtual password : String
  virtual password_confirmation : String

  def prepare
    validate_uniqueness_of email
    run_password_validations
    Authentic.copy_and_encrypt password, to: encrypted_password
  end
end
