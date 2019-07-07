# Borrowed from
# https://github.com/luckyframework/lucky/blob/master/spec/support/context_helper.cr
# Added some _friendly_ methods (that needs to be refactored) to support auth
#
module ContextHelper
  include Auth::GenerateToken

  # My Methods
  private def delete(user : User, params = {} of String => String)
    headers = build_headers({"Authorization" => "Token #{generate_token(user)}"}, content_type: :json)
    request = build_request method: "DELETE", body: params.to_json, headers: headers

    build_context(request: request)
  end

  private def get(user : User, params = {} of String => String)
    headers = build_headers({"Authorization" => "Token #{generate_token(user)}"}, content_type: :json)
    request = build_request method: "GET", body: params.to_json, headers: headers

    build_context(request: request)
  end

  private def post(user : User, params = {} of String => String)
    headers = build_headers({"Authorization" => "Token #{generate_token(user)}"}, content_type: :json)
    request = build_request method: "POST", body: params.to_json, headers: headers

    build_context(request: request)
  end

  private def post(params = {} of String => String)
    headers = build_headers(content_type: :json)
    request = build_request method: "POST", body: params.to_json, headers: headers

    build_context(request: request)
  end

  private def build_headers(headers = {} of String => String, content_type = nil)
    building_headers = HTTP::Headers.new
    headers.each do |k, v|
      building_headers.add(k, v)
    end
    building_headers.add("Content-Type", "application/json") if content_type == :json
    building_headers
  end

  # Lucky Methods
  private def build_request(method = "GET", body = "", content_type = "")
    headers = HTTP::Headers.new
    headers.add("Content-Type", content_type)
    HTTP::Request.new(method, "/", body: body, headers: headers)
  end

  private def build_request(method = "GET", body = "", content_type = "", headers = {} of String => String)
    HTTP::Request.new(method, "/", body: body, headers: headers)
  end

  private def build_context(path = "/", request = nil) : HTTP::Server::Context
    build_context_with_io(IO::Memory.new, path: path, request: request)
  end

  private def build_context(user : User, method = "GET", path = "/", request = nil) : HTTP::Server::Context
    headers = HTTP::Headers.new
    headers.add("Content-Type", "")
    headers.add("Authorization", "Token #{generate_token(user)}")

    build_context_with_io(
      IO::Memory.new,
      path: "/",
      request: build_request("GET", headers: headers),
    )
  end

  private def build_context(method : String) : HTTP::Server::Context
    build_context_with_io(
      IO::Memory.new,
      path: "/",
      request: build_request(method)
    )
  end

  private def build_context_with_io(io : IO, path = "/", request = nil) : HTTP::Server::Context
    request = request || HTTP::Request.new("GET", path)
    response = HTTP::Server::Response.new(io)
    HTTP::Server::Context.new request, response
  end

  private def build_context_with_flash(flash : String)
    build_context.tap do |context|
      context.session.set(Lucky::FlashStore::SESSION_KEY, flash)
    end
  end

  private def params
    {} of String => String
  end
end
