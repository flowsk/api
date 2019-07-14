module Gateway
  alias RouteContext = NamedTuple(action: Gateway::Operation, params: Hash(String, String))
  alias ParamsType = Nil | Bool | Int32 | Int64 | Float64 | String | JSON::Any |
                     Hash(String, ParamsType) |
                     Hash(String, JSON::Any) |
                     Array(ParamsType) |
                     Array(JSON::Any)
  alias Params = Hash(String, ParamsType)
end

require "./gateway/**"
