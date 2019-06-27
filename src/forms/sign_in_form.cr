class SignInForm < Avram::VirtualForm
  include Authentic::FormHelpers
  include FindAuthenticatable

  virtual email : String
  virtual password : String

  private def validate(user : User?)
    if user
      unless Authentic.correct_password?(user, password.value.to_s)
        password.add_error "is wrong"
      end
    else
      email.add_error "is not in our system"
    end
  end
end
