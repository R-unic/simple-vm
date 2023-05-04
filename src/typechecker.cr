module Types
  alias ValidType = Int64 | Int32 | Float64 | String | VM | Closure | Nil
end


module TypeChecker(T)
  def self.assert_operands(left : Types::ValidType, right : Types::ValidType)
    raise "Invalid left operand type: #{typeof(left)}" unless left.is_a?(T)
    raise "Invalid right operand type: #{typeof(right)}" unless right.is_a?(T)
  end

  def self.assert(operand : Types::ValidType)
    raise "Invalid operand type: #{typeof(operand)}" unless operand.is_a?(T)
  end
end
