require "./types"
include Types

module TypeChecker(T)
  def self.assert_operands(left : ValidType, right : ValidType)
    raise "Invalid left operand type: #{typeof(left)}" unless left.is_a?(T)
    raise "Invalid right operand type: #{typeof(right)}" unless right.is_a?(T)
  end

  def self.assert(operand : ValidType)
    raise "Invalid operand type: #{typeof(operand)}" unless operand.is_a?(T)
  end
end
