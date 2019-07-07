module Api::V1
  abstract class AuthenticatedAction < ApiAction
    include Auth::UserFromToken

    before require_current_user

    getter current_user : User? = nil

    private def require_current_user
      auth_header = context.request.headers["Authorization"]
      token = auth_header.split(" ")[1]

      if token.nil?
        head 401
      else
        @current_user = user_from_token(token)
      end

      if @current_user.nil?
        head 401
      else
        continue
      end
    rescue JWT::ExpiredSignatureError
      head 401
    end

    def current_user
      @current_user.not_nil!
    end
  end
end
