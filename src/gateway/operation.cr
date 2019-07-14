module Gateway
  module Operation
    def self.operation
      new
    end

    abstract def run(params : Gateway::Params)
  end
end
