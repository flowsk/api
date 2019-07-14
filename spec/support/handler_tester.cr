module HandlerTester(T)
  def get(path, headers = HTTP::Headers.new)
    request = HTTP::Request.new("GET", path)
    response = create_http_request_and_return_response(T, request)
  end

  def post(path, headers = HTTP::Headers.new, params = "")
    request = HTTP::Request.new("POST", path, body: params.to_json)
    response = create_http_request_and_return_response(T, request)
  end

  private def headers
    HTTP::Headers{
      "Accept" => "html",
    }
  end

  def create_http_request_and_return_response(handler, request)
    io = IO::Memory.new
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)
    begin
      handler.new.call context
    rescue IO::Error
      # Raises because the IO::Memory is empty
    end
    response.close
    io.rewind
    HTTP::Client::Response.from_io(io, decompress: false)
  end
end
