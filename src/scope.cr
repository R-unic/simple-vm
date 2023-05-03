require "./types"

class Scope
  @variables : Hash(String, Types::ValidType)
  @parent : Scope? = nil

  def initialize(parent = nil)
    @parent = parent
    @variables = {} of String => Types::ValidType
  end

  def lookup(name : String) : Types::ValidType
    if @variables.has_key?(name)
      return @variables[name]
    elsif parent = @parent
      return parent.lookup(name)
    else
      return "nil"
    end
  end

  def assign(name : String, value : Types::ValidType)
    @variables[name] = value
  end
end
