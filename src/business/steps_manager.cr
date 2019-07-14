class Business::StepsManager
  @steps = [] of NamedTuple(name: Symbol, kind: Symbol, track: Symbol)
  @macros : Hash(Symbol, Business::Step.class) = Hash(Symbol, Business::Step.class).new
  @blocks = {} of Symbol => Proc(Operation::Context, Operation::Params, Bool)

  def add(step : Symbol)
    @steps << {name: step, kind: :block, track: :right}
  end

  def add(step : Symbol, klass : Business::Step.class)
    @steps << {name: step, kind: :macro, track: :right}
    @macros[step] = klass
  end

  def failure(step : Symbol)
    @steps << {name: step, kind: :block, track: :left}
  end

  def add_block(name, content)
    @blocks[name] = content
  end

  def all
    @steps
  end

  def get_macro(name)
    @macros[name]
  end

  def get_block(name)
    @blocks[name]
  end
end
