require "radix"

module Gateway
  class Handler
    include HTTP::Handler

    getter :router
    HTTP_METHODS = %w(get post put patch delete options)

    def initialize
      @router = Gateway::Router.new
      routes
    end

    def call(context)
      if route_context = router.search_route(context)
        params = extract_params(context, route_context[:params])
        operation = route_context[:action]
        endpoint.call(context, params, operation)
        context
      else
        call_next(context)
      end
    end

    def routes
    end

    def endpoint : Gateway::Endpoint
      Gateway::EndpointDefault.new
    end

    {% for http_method in HTTP_METHODS %}
    def {{http_method.id}}(path : String, operation)
      @router.add_route("/{{http_method.id.upcase}}" + path, operation.new)
    end
    {% end %}

    def extract_params(context, url_params)
      json = Gateway::Params.new

      body = context.request.body
      if body.is_a?(IO)
        case request_json = ::JSON.parse(body.gets_to_end).raw
        when Hash
          request_json.each do |key, value|
            json[key] = value.raw
          end
        when Array
          json["_json"] = json
        end
      end

      json.merge!(url_params)
    end
  end
end
