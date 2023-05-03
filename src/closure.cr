require "./scope"

class Closure
  def initialize(
    @name : String,
    @function_def : VM,
    @scope : Scope,
    @arg_names : Array(String)
  ) end

  def call(*args)
    local_scope = Scope.new(@scope)
    args.each_with_index { |arg, i| local_scope.assign(@arg_names[i], arg) }
    VM.new(@function_def.bytecode, @function_def.memory, local_scope).run
  end
end
