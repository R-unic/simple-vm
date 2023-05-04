require "./closure"

class Scope
  @variables : Hash(String, ValidType)
  @parent : Scope? = nil

  def initialize(parent = nil)
    @parent = parent
    @variables = {} of String => ValidType
  end

  # Looks up a variable in this scope and parent scopes
  def lookup(name : String) : ValidType
    return @variables[name] if @variables.has_key?(name)
    if parent = @parent
      return parent.lookup(name)
    end
    raise "Undefined variable: #{name}"
  end

  # Assigns a variable to the local scope, this is not global
  def assign(name : String, value : ValidType)
    raise "Invalid variable identifier: #{name}" unless valid_identifier?(name, value.is_a?(Closure))
    @variables[name] = value
  end

  # Returns whether or not `identifier` is valid
  # `is_method` is only used to determine if a question mark at the end of the identifier is valid
  private def valid_identifier?(identifier : String, is_method : Bool) : Bool
    is_method ? !!(identifier =~ /^[a-zA-Z_][a-zA-Z0-9_$]*\??$/) : !!(identifier =~ /^[a-zA-Z_][a-zA-Z0-9_$]*$/)
  end
end
