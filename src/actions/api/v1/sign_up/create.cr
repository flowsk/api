class Api::V1::SignUp::Create < ApiAction
  include Auth::GenerateToken

  route do
    SignUpForm.create(params) do |form, user|
      if user
        token = generate_token(user)
        json ({"token" => token})
      else
        head 401
      end
    end
  rescue e : Exception
    head 401
  end
end
