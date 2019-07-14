require "./business/*"

module Business
  alias Types = Nil | Bool | Int32 | Int64 | Float64 | String | JSON::Any |
                Hash(String, Types) |
                Hash(String, JSON::Any) |
                Array(Types) |
                Array(JSON::Any)

  alias Params = Hash(String, Types)

  macro define_type(const)
    class Business::Operation::Context
      define_type({{const}})
    end
  end

  define_type(Business::Types)
end
