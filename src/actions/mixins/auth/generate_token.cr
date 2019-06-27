require "jwt"

module Auth
  module GenerateToken
    def generate_token(user)
      exp = (Time.utc + 14.days).to_unix
      data = ({id: user.id, name: user.name, email: user.email}).to_s
      payload = {"sub" => user.id, "user" => Base64.encode(data), "exp" => exp}

      JWT.encode(payload, Lucky::Server.settings.secret_key_base, JWT::Algorithm::HS256)
    end
  end
end
