require "./types"
require "./scope"
require "./opcodes"
require "./typechecker"

class VM
  getter bytecode : Array(Int32 | Op)
  getter memory : Array(Types::ValidType)

  def initialize(
    @bytecode : Array(Int32 | Op),
    @memory : Array(Types::ValidType),
    scope : Scope? = nil
  )
    @scope = scope || Scope.new
    @stack = [] of Types::ValidType
    @ptr = 0

    raise "No END or RETURN instruction found in bytecode" unless @bytecode.includes?(Op::END) || @bytecode.includes?(Op::RETURN)
  end

  def run
    while @ptr < @bytecode.size
      op = @bytecode[@ptr]
      case op
      when Op::END
        break
      when Op::ECHO
        value = @stack.pop
        puts value
        @ptr += 1
      when Op::PUSH
        @stack << @memory[@bytecode[@ptr + 1].to_i]
        @ptr += 2
      when Op::POP
        @stack.pop
        @ptr += 1
      when Op::SWAP
        right = @stack.pop
        left = @stack.pop
        @stack << right
        @stack << left
        @ptr += 1
      when Op::DUP
        value = @stack[-1]
        @stack << value
        @ptr += 1
      when Op::LOAD
        name = @memory[@bytecode[@ptr + 1].to_i].to_s
        @stack << @scope.lookup(name)
        @ptr += 2
      when Op::STORE
        name = @memory[@bytecode[@ptr + 1].to_i].to_s
        value = @stack.pop
        @scope.assign(name, value)
        @ptr += 2
      when Op::RETURN; return @stack.pop
      when Op::PROC
        name = @memory[@bytecode[@ptr + 1].to_i].to_s # get the function name from the address provided
        definition = @stack.pop # pop the VM to be wrapped in a closure
        TypeChecker(VM).assert(definition)

        arg_count = @bytecode[@ptr + 2].to_i # get the argument amount provided
        arg_names = [] of String
        arg_count.times do
          arg_name = @stack.pop
          TypeChecker(String).assert(arg_name)
          arg_names << arg_name.to_s
        end

        closure = Closure.new(name, definition.as(VM), @scope, arg_names)
        @scope.assign(name, closure)
        @stack << closure
        @ptr += 3
      when Op::CALL
        arg_values = [] of Types::ValidType
        arg_count = @bytecode[@ptr + 1].to_i # get the argument amount provided
        var_addr = @bytecode[@ptr + 2].to_i # get the function name address provided
        arg_count.times do
          value = @stack.pop
          arg_values << value
        end

        var_name = @memory[var_addr].to_s
        closure = @scope.lookup(var_name)
        TypeChecker(Closure).assert(closure)
        @stack << closure.as(Closure).call(arg_values)
        @ptr += 3
      when Op::CONCAT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(String).assert_operands(left, right)
        @stack << (left.to_s + right.to_s)
        @ptr += 1
      when Op::ADD
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64) + right.as(Float64 | Int64))
        @ptr += 1
      when Op::SUB
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64) - right.as(Float64 | Int64))
        @ptr += 1
      when Op::MUL
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64) * right.as(Float64 | Int64))
        @ptr += 1
      when Op::DIV
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64) / right.as(Float64 | Int64))
        @ptr += 1
      when Op::POW
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64) ** right.as(Float64 | Int64))
        @ptr += 1
      when Op::MOD
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) % right.as(Int64))
        @ptr += 1
      when Op::BSHL
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) << right.as(Int64))
        @ptr += 1
      when Op::BSHR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) >> right.as(Int64))
        @ptr += 1
      when Op::BNOT
        operand = @stack.pop
        TypeChecker(Int64).assert(operand)
        @stack << ~operand.as(Int64)
        @ptr += 1
      when Op::BAND
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) & right.as(Int64))
        @ptr += 1
      when Op::BOR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) | right.as(Int64))
        @ptr += 1
      when Op::BXOR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) ^ right.as(Int64))
        @ptr += 1
      when Op::AND
        right = @stack.pop
        left = @stack.pop
        @stack << ((left && right) ? 1 : 0)
        @ptr += 1
      when Op::OR
        right = @stack.pop
        left = @stack.pop
        @stack << ((left || right) ? 1 : 0)
        @ptr += 1
      when Op::NOT
        operand = @stack.pop
        @stack << (!operand ? 1 : 0)
        @ptr += 1
      when Op::LT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64) < right.as(Float64 | Int64)) ? 1 : 0)
        @ptr += 1
      when Op::LTE
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64) <= right.as(Float64 | Int64)) ? 1 : 0)
        @ptr += 1
      when Op::GT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64) > right.as(Float64 | Int64)) ? 1 : 0)
        @ptr += 1
      when Op::GTE
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64) >= right.as(Float64 | Int64)) ? 1 : 0)
        @ptr += 1
      when Op::EQ
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64) == right.as(Float64 | Int64)) ? 1 : 0)
        @ptr += 1
      when Op::JMP
        @ptr = @bytecode[@ptr + 1].to_i
      when Op::JNZ
        value = @stack.pop
        if value != 0.0_f32
          @ptr = @bytecode[@ptr + 1].to_i
        else
          @ptr += 2
        end
      when Op::JZ
        value = @stack.pop
        if value == 0.0_f32
          @ptr = @bytecode[@ptr + 1].to_i
        else
          @ptr += 2
        end
      end
    end
  end
end
