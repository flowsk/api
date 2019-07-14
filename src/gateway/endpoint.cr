module Gateway
  module Endpoint
    def self.call(context, params, operation)
      endpoint.call(context, params, operation)
    end

    def self.endpoint
      new
    end

    abstract def call(context : HTTP::Server::Context, params : Gateway::Params, operation : Gateway::Operation) : HTTP::Server::Context
  end
end
