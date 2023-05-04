require "./typechecker"; include Types;
require "./scope"
require "./opcodes"

class VM
  getter bytecode : Array(Int32 | Op)
  getter memory : Array(ValidType)
  getter stack : Array(ValidType)

  def initialize(
    @bytecode : Array(Int32 | Op),
    @memory : Array(ValidType),
    scope : Scope? = nil
  )
    @scope = scope || Scope.new
    @stack = [] of ValidType
    @ptr = 0

    raise "No END or RETURN instruction found in bytecode" unless @bytecode.includes?(Op::END) || @bytecode.includes?(Op::RETURN)
  end

  # Loads an address from memory
  # Takes a number to offset the instruction pointer by
  # ```
  # load_from_memory 1
  # ```
  private def load_from_memory(offset : Int32)
    @memory[@bytecode[@ptr + offset].to_i]
  end

  # Advances the instruction pointer
  # ```
  # advance
  # advance 2
  # ```
  private def advance(n : Int32 = 1)
    @ptr += n
  end

  def run
    length = @bytecode.size
    while @ptr < length
      op = @bytecode[@ptr]
      case op
      when Op::NOOP
        advance
      when Op::END
        break
      when Op::ECHO
        value = @stack.pop
        puts value
        @stack << value
        advance
      when Op::PUSH
        @stack << load_from_memory(1)
        advance 2
      when Op::POP
        @stack.pop
        advance
      when Op::SWAP
        right = @stack.pop
        left = @stack.pop
        @stack << right
        @stack << left
        advance
      when Op::DUP
        value = @stack.last
        @stack << value
        advance
      when Op::LOAD
        name = load_from_memory(1).to_s
        @stack << @scope.lookup(name)
        advance 2
      when Op::STORE
        name = load_from_memory(1).to_s
        value = @stack.pop
        @scope.assign(name, value)
        advance 2
      when Op::RETURN; return @stack.pop
      when Op::PROC
        name = load_from_memory(1).to_s # get the function name from the address provided
        definition = @stack.pop # pop the VM to be wrapped in a closure
        TypeChecker(VM).assert(definition)

        arg_count = @bytecode[@ptr + 2].to_i # get the argument amount provided
        arg_names = Array(String).new(arg_count) do
          arg_name = @stack.pop
          TypeChecker(String).assert(arg_name)
          arg_name.to_s
        end

        closure = Closure.new(name, definition.as(VM), @scope, arg_names)
        @scope.assign(name, closure)
        advance 3
      when Op::CALL
        arg_count = @bytecode[@ptr + 2].to_i # get the argument amount provided
        arg_values = Array(ValidType).new(arg_count) { @stack.pop }

        var_name = load_from_memory(1).to_s
        closure = @scope.lookup(var_name)
        TypeChecker(Closure).assert(closure)
        @stack << closure.as(Closure).call(arg_values)
        advance 3
      when Op::CONCAT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(String).assert_operands(left, right)
        @stack << (left.to_s + right.to_s)
        advance
      when Op::ADD
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64 | Int32) + right.as(Float64 | Int64 | Int32))
        advance
      when Op::SUB
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64 | Int32) - right.as(Float64 | Int64 | Int32))
        advance
      when Op::MUL
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64 | Int32) * right.as(Float64 | Int64 | Int32))
        advance
      when Op::DIV
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64 | Int32) / right.as(Float64 | Int64 | Int32))
        advance
      when Op::POW
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << (left.as(Float64 | Int64 | Int32) ** right.as(Float64 | Int64 | Int32))
        advance
      when Op::MOD
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) % right.as(Int64))
        advance
      when Op::BSHL
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) << right.as(Int64))
        advance
      when Op::BSHR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) >> right.as(Int64))
        advance
      when Op::BNOT
        operand = @stack.pop
        TypeChecker(Int64).assert(operand)
        @stack << ~operand.as(Int64)
        advance
      when Op::BAND
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) & right.as(Int64))
        advance
      when Op::BOR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) | right.as(Int64))
        advance
      when Op::BXOR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Int64).assert_operands(left, right)
        @stack << (left.as(Int64) ^ right.as(Int64))
        advance
      when Op::AND
        right = @stack.pop
        left = @stack.pop
        @stack << ((left && right) ? 1 : 0)
        advance
      when Op::OR
        right = @stack.pop
        left = @stack.pop
        @stack << ((left || right) ? 1 : 0)
        advance
      when Op::NOT
        operand = @stack.pop
        @stack << (!operand ? 1 : 0)
        advance
      when Op::LT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64 | Int32) < right.as(Float64 | Int64 | Int32)) ? 1 : 0)
        advance
      when Op::LTE
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64 | Int32) <= right.as(Float64 | Int64 | Int32)) ? 1 : 0)
        advance
      when Op::GT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64 | Int32) > right.as(Float64 | Int64 | Int32)) ? 1 : 0)
        advance
      when Op::GTE
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64 | Int32) >= right.as(Float64 | Int64 | Int32)) ? 1 : 0)
        advance
      when Op::EQ
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float64 | Int64 | Int32).assert_operands(left, right)
        @stack << ((left.as(Float64 | Int64 | Int32) == right.as(Float64 | Int64 | Int32)) ? 1 : 0)
        advance
      when Op::JMP
        @ptr = @bytecode[@ptr + 1].to_i
      when Op::JNZ
        value = @stack.pop
        if value != 0
          @ptr = @bytecode[@ptr + 1].to_i
        else
          advance 2
        end
      when Op::JZ
        value = @stack.pop
        if value == 0
          @ptr = @bytecode[@ptr + 1].to_i
        else
          advance 2
        end
      end
    end
  end
end
