module Business
  abstract class Step
    abstract def run(ctx : Business::Context, params : Operation::Params)
  end
end
