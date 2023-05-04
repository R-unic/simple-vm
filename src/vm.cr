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

    raise "No HALT instruction found in bytecode" unless @bytecode.includes?(Op::HALT)
  end

  def run
    while @ptr < @bytecode.size
      op = @bytecode[@ptr]
      case op
      when Op::HALT
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
      when Op::PROC
        name = @memory[@bytecode[@ptr + 1].to_i].to_s
        definition = @stack.pop
        TypeChecker(VM).assert(definition)

        arg_count = @bytecode[@ptr + 2].to_i
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
        arg_count = @bytecode[@ptr + 1].to_i
        arg_count.times do
          value = @stack.pop
          arg_values << value
        end

        closure = @stack.pop
        TypeChecker(Closure).assert(closure)
        closure.as(Closure).call(arg_values)
        @ptr += 2
      when Op::CONCAT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(String).assert_operands(left, right)
        @stack << (left.to_s + right.to_s)
        @ptr += 1
      when Op::ADD
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32) + right.as(Float32))
        @ptr += 1
      when Op::SUB
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32) - right.as(Float32))
        @ptr += 1
      when Op::MUL
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32) * right.as(Float32))
        @ptr += 1
      when Op::DIV
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32) / right.as(Float32))
        @ptr += 1
      when Op::POW
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32) ** right.as(Float32))
        @ptr += 1
      when Op::MOD
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32) % right.as(Float32))
        @ptr += 1
      when Op::BSHL
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32).to_i << right.as(Float32).to_i).to_f32
        @ptr += 1
      when Op::BSHR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32).to_i >> right.as(Float32).to_i).to_f32
        @ptr += 1
      when Op::BNOT
        operand = @stack.pop
        TypeChecker(Float32).assert(operand)
        @stack << (~operand.as(Float32).to_i).to_f32
        @ptr += 1
      when Op::BOR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32).to_i | right.as(Float32).to_i).to_f32
        @ptr += 1
      when Op::BXOR
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32).to_i ^ right.as(Float32).to_i).to_f32
        @ptr += 1
      when Op::BAND
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << (left.as(Float32).to_i & right.as(Float32).to_i).to_f32
        @ptr += 1
      when Op::AND
        right = @stack.pop
        left = @stack.pop
        @stack << ((left && right) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::OR
        right = @stack.pop
        left = @stack.pop
        @stack << ((left || right) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::NOT
        operand = @stack.pop
        @stack << (!operand ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::LT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << ((left.as(Float32) < right.as(Float32)) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::LTE
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << ((left.as(Float32) <= right.as(Float32)) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::GT
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << ((left.as(Float32) > right.as(Float32)) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::GTE
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << ((left.as(Float32) >= right.as(Float32)) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::EQ
        right = @stack.pop
        left = @stack.pop
        TypeChecker(Float32).assert_operands(left, right)
        @stack << ((left.as(Float32) == right.as(Float32)) ? 1_f32 : 0_f32)
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

do_something = VM.new [
  Op::LOAD, 0,
  Op::ECHO,
  Op::LOAD, 1,
  Op::ECHO,
  Op::LOAD, 2,
  Op::ECHO,
  Op::HALT
], ["a", "b", "c"] of Types::ValidType

vm = VM.new [ # a = "something" (define do_something) do_something("some value")
  Op::PUSH, 0, # "something"
  Op::STORE, 1,

  Op::PUSH, 5, # "b"
  Op::PUSH, 7, # "c"
  Op::PUSH, 3, # VM<do_something>
  Op::PROC, 2, 2,

  Op::PUSH, 4, # "some value"
  Op::PUSH, 6, # "some other value"
  Op::CALL, 2,
  Op::HALT
], ["something", "a", "func", do_something, "some value", "b", "some other value", "c"] of Types::ValidType

vm.run
