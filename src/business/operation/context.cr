class Business::Operation
  class Context
    class MutateDataException < Exception
    end

    macro define_type(const)
      @ctx : Hash(String, {{const}})

      def initialize
        @ctx = {} of String => {{const}}
      end

      def []=(key : String, value : {{const}})
        raise MutateDataException.new("Do not change existing #{key} key") if @ctx.has_key?(key)
        @ctx[key] = value
      end

      def [](key)
        @ctx[key]
      end
    end
  end
end
