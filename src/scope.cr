require "./closure"

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
    raise "Invalid variable identifier: #{name}" unless valid_identifier?(name, value.is_a?(Closure))
    @variables[name] = value
  end

  private def valid_identifier?(identifier : String, is_method : Bool) : Bool
    is_method ? !!(identifier =~ /^[a-zA-Z_][a-zA-Z0-9_$]*\??$/) : !!(identifier =~ /^[a-zA-Z_][a-zA-Z0-9_$]*$/)
  end
end
