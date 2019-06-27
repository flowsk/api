module Auth
  module UserFromToken
    def user_from_token(token : String)
      payload, _header = JWT.decode(token, Lucky::Server.settings.secret_key_base, JWT::Algorithm::HS256)
      UserQuery.new.find(payload["sub"].to_s)
    end
  end
end
