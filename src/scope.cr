require "./closure"

# TODO: invalid variable identifiers
class Scope
  @variables : Hash(String, ValidType)
  @parent : Scope? = nil

  def initialize(parent = nil)
    @parent = parent
    @variables = {} of String => ValidType
  end

  def lookup(name : String) : ValidType
    return @variables[name] if @variables.has_key?(name)
    if parent = @parent
      return parent.lookup(name)
    end
    raise "Undefined variable: #{name}"
  end

  def assign(name : String, value : ValidType)
    @variables[name] = value
  end
end
