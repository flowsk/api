require "./operation/context"
require "./step"

module Business
  class Operation
    alias Params = Hash(String, Types)

    @@steps : StepsManager = StepsManager.new

    def self.step(step : Symbol)
      @@steps.add(step)
    end

    def self.step(step : Symbol, klass : Business::Step.class)
      @@steps.add(step, klass)
    end

    def self.failure(step : Symbol)
      @@steps.failure(step)
    end

    def self.failure(step : Symbol, klass : Business::Step.class)
      @@steps << {name: step, kind: :macro, track: :left}
      @@macros[step] = klass
    end

    macro define_step(name, content)
      @@steps.add_block({{name}}, {{content}})
    end

    def self.run(params : Hash, **other)
      op = new
      op.run(params: params, other: other)
      op
    end

    def initialize
      @ctx = Context.new
      @track = :right
    end

    def run(params : Params, **other)
      @@steps.all.each do |step|
        ret_value = run_step(step, @ctx, params)
        @track = :left if ret_value == false
      end
      true
    end

    def run_step(step, ctx, params)
      return true if step[:track] != @track
      return @@steps.get_macro(step[:name]).new.run(ctx, params) if step[:kind] == :macro
      return @@steps.get_block(step[:name]).call(ctx, params) if step[:kind] == :block
      true
    end

    def run(params : Endpoint::HTTP::Params, **other)
      op_params = Params.new
      op_params.merge!(params)
      run(op_params)
    end

    def success?
      @track == :right
    end

    def [](index)
      @ctx[index]
    end
  end
end
