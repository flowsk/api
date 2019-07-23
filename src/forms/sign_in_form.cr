class SignInForm < Avram::Operation
  include FindAuthenticatable

  param_key :sign_in

  attribute email : String
  attribute password : String

  def validate(user : User)
    if user
      unless Authentic.correct_password?(user, password.value.to_s)
        password.add_error "is wrong"
      end
    else
      email.add_error "is not in our system"
    end
  end
end
