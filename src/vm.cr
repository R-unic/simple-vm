require "./types"
require "./scope"
require "./opcodes"

class VM
  def initialize(bytecode : Array(Int32 | Op), memory : Array(Types::ValidType))
    @bytecode = bytecode
    @memory = memory
    @scope = Scope.new
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
      when Op::CONCAT
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_s + right.to_s)
        @ptr += 1
      when Op::ADD
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_f32 + right.to_f32)
        @ptr += 1
      when Op::SUB
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_f32 - right.to_f32)
        @ptr += 1
      when Op::MUL
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_f32 * right.to_f32)
        @ptr += 1
      when Op::DIV
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_f32 / right.to_f32)
        @ptr += 1
      when Op::POW
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_f32 ** right.to_f32)
        @ptr += 1
      when Op::MOD
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_f32 % right.to_f32)
        @ptr += 1
      when Op::BSHL
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_i << right.to_i).to_f32
        @ptr += 1
      when Op::BSHR
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_i >> right.to_i).to_f32
        @ptr += 1
      when Op::BNOT
        operand = @stack.pop
        @stack << (~operand.to_i).to_f32
        @ptr += 1
      when Op::BOR
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_i | right.to_i).to_f32
        @ptr += 1
      when Op::BXOR
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_i ^ right.to_i).to_f32
        @ptr += 1
      when Op::BAND
        right = @stack.pop
        left = @stack.pop
        @stack << (left.to_i & right.to_i).to_f32
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
        @stack << ((left.to_f32 < right.to_f32) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::LTE
        right = @stack.pop
        left = @stack.pop
        @stack << ((left.to_f32 <= right.to_f32) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::GT
        right = @stack.pop
        left = @stack.pop
        @stack << ((left.to_f32 > right.to_f32) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::GTE
        right = @stack.pop
        left = @stack.pop
        @stack << ((left.to_f32 >= right.to_f32) ? 1_f32 : 0_f32)
        @ptr += 1
      when Op::EQ
        right = @stack.pop
        left = @stack.pop
        @stack << ((left.to_f32 == right.to_f32) ? 1_f32 : 0_f32)
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

vm = VM.new [
  Op::PUSH, 0,
  Op::STORE, 1,
  Op::LOAD, 1,
  Op::ECHO,
  Op::HALT
], [12_f32, "a"] of Types::ValidType

vm.run
