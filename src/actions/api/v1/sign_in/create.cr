class Api::V1::SignIn::Create < ApiAction
  include Auth::GenerateToken

  route do
    SignInForm.new(params).submit do |form, user|
      if user
        context.response.headers.add "Authorization", generate_token(user)
        head 200
      else
        head 401
      end
    end
  end
end
