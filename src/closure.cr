require "./scope"

class Closure
  getter scope : Scope

  def initialize(
    @name : String,
    @function_def : VM,
    scope : Scope
  )
    @scope = Scope.new(scope)
  end

  def call
    VM.new(@function_def.bytecode, @function_def.memory, @scope).run
  end
end
