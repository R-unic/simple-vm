require "./types"

module TypeChecker(T)
  def self.assert_operands(left : Types::ValidType, right : Types::ValidType)
    raise "Invalid left operand type: #{typeof(left)}" if typeof(left.as(T)) != T
    raise "Invalid right operand type: #{typeof(right)}" if typeof(right.as(T)) != T
  end

  def self.assert(operand : Types::ValidType)
    raise "Invalid operand type: #{typeof(operand)}" if typeof(operand.as(T)) != T
  end
end
