module Gateway
  class EndpointDefault
    include Gateway::Endpoint

    def call(context, params, operation)
      context.response.print ""
    end
  end
end
