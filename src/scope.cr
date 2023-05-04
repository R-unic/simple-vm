require "./closure"

# TODO: invalid variable identifiers, already defined variables, undefined variables
class Scope
  @variables : Hash(String, ValidType)
  @parent : Scope? = nil

  def initialize(parent = nil)
    @parent = parent
    @variables = {} of String => ValidType
  end

  def lookup(name : String) : ValidType
    if @variables.has_key?(name)
      return @variables[name]
    elsif parent = @parent
      return parent.lookup(name)
    else
      return "nil"
    end
  end

  def assign(name : String, value : ValidType)
    @variables[name] = value
  end
end
