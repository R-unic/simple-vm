require "./types"

module TypeChecker(T)
  def self.assert_operands(left : Types::ValidType, right : Types::ValidType)
    raise "Invalid left operand type: #{typeof(left)}" if !left.is_a?(T)
    raise "Invalid right operand type: #{typeof(right)}" if !left.is_a?(T)
  end

  def self.assert(operand : Types::ValidType)
    raise "Invalid operand type: #{typeof(operand)}" if !operand.is_a?(T)
  end
end
