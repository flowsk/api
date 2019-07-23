class Api::V1::SignIn::Create < ApiAction
  include Auth::GenerateToken
  include FindAuthenticatable

  route do
    user = params.nested("sign_in").get("email").try do |value|
      UserQuery.new.email(value).first?
    end

    if user && (password = params.nested("sign_in").get("password"))
      if Authentic.correct_password?(user, password)
        token = generate_token(user)
        json ({"token" => token})
      else
        head 401
      end
    else
      head 401
    end
  rescue e : Exception
    head 401
  end
end
