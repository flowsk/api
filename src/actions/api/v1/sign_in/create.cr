class Api::V1::SignIn::Create < ApiAction
  include Auth::GenerateToken

  route do
    SignInForm.new(params).submit do |form, user|
      if user
        token = generate_token(user)
        json ({"token" => token})
      else
        head 401
      end
    end
  end
end
