module Gateway
  class Router
    def initialize
      @tree = Radix::Tree(Gateway::Operation).new
      @static_routes = {} of String => Gateway::Operation
    end

    def search_route(context : HTTP::Server::Context) : RouteContext?
      search_path = "/" + context.request.method + context.request.path
      action = @static_routes[search_path]?
      return {action: action, params: {} of String => String} if action

      route = @tree.find(search_path)
      return {action: route.payload, params: route.params} if route.found?

      nil
    end

    def add_route(key : String, action : Gateway::Operation)
      if key.includes?(':') || key.includes?('*')
        @tree.add(key, action)
      else
        @static_routes[key] = action
        if key.ends_with? '/'
          @static_routes[key[0..-2]] = action
        else
          @static_routes[key + "/"] = action
        end
      end
    end
  end
end
