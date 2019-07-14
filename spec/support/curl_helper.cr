module CurlHelper(T)
  macro included
    StartServer.build(T.new)
  end

  def curl(method : String, path : String) : HTTP::Client::Response
    host, port = StartServer.listen_address.to_s.split(":")
    client = HTTP::Client.new host, port

    case method
    when "GET"
      response = client.get path
      client.close
      return response
    when "POST"
      response = client.post path
      client.close
      return response
    when "PUT"
      response = client.put path
      client.close
      return response
    else
      response = client.put path
      client.close
      return response
    end
  end

  def curl(method : String, path : String, json : String) : HTTP::Client::Response
    host, port = StartServer.listen_address.to_s.split(":")
    client = HTTP::Client.new host, port

    response = client.post path, body: json
    client.close
    response
  end

  class StartServer
    @@listen_address : Socket::IPAddress = Socket::IPAddress.new("127.0.0.1", 80)

    def self.build(handler : HTTP::Handler)
      address_chan = Channel(Socket::IPAddress).new

      spawn do
        # Make pinger real fast so we don't need to wait
        http_ref = nil
        http_server = http_ref = HTTP::Server.new([handler])
        address = http_server.bind_unused_port
        address_chan.send(address)
        http_server.listen
      end

      @@listen_address = address_chan.receive
    end

    def self.listen_address
      @@listen_address
    end
  end
end
