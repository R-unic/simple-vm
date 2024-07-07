require "./spec_helper"

describe VM do
  describe "#run" do
    it "should run hello world" do
      vm = VM.new [
        Op::PUSH, 0,
        Op::PUSH, 1,
        Op::CONCAT,
        Op::EXIT
      ], ["hello ", "world"] of ValidType

      vm.run
      vm.stack.first.should eq("hello world")
    end

    it "should be able to define & load variables" do
      vm = VM.new [
        Op::PUSH, 0,
        Op::STORE, 1,
        Op::LOAD, 1,
        Op::EXIT
      ], ["hello world", "this$Is_Valid"] of ValidType

      vm.run
      vm.stack.first.should eq("hello world")
    end

    it "should be able to create & index arrays" do
      vm = VM.new [ # a = ["hello", "world"]; puts a[1]
        Op::PUSH, 0,
        Op::STORE, 1,
        Op::LOAD, 1,
        Op::INDEX, 2,
        Op::EXIT
      ], [["hello", "world"] of BaseValidType, "a", 1_i64] of ValidType

      vm.run
      vm.stack.first.should eq("world")
    end

    it "should be able to do math" do
      vm = VM.new [ # 6 * (14 / (6 + (12 - (3 * 17))))
        Op::PUSH, 0,
        Op::PUSH, 1,
        Op::PUSH, 2,
        Op::PUSH, 3,
        Op::PUSH, 4,
        Op::PUSH, 5,
        Op::MUL,
        Op::SUB,
        Op::ADD,
        Op::DIV,
        Op::MUL,
        Op::EXIT
      ], [6, 14, 6, 12, 3, 17] of ValidType

      vm.run
      vm.stack.first.should eq(-2.5454545454545454)
    end

    it "should run fibonacci sequence" do
      fib = VM.new [
        Op::LOAD, 0, # n
        Op::PUSH, 2, # 1
        Op::LTE,

        Op::JZ, 10, # if false jump to 11 (noop)
        Op::LOAD, 0, # n
        Op::RETURN,

        Op::NOOP, # else branch
        Op::PUSH, 1, # 0
        Op::STORE, 4, # a = 0
        Op::PUSH, 2, # 1
        Op::STORE, 5, # b = 1
        Op::PUSHNIL,
        Op::STORE, 6, # c = nil
        Op::PUSH, 3, # 2
        Op::STORE, 7, # i = 2

        Op::NOOP, # for loop
        Op::LOAD, 4, # a
        Op::LOAD, 5, # b
        Op::ADD, # a + b
        Op::STORE, 6, # c = a + b
        Op::LOAD, 5, # b
        Op::STORE, 4, # a = b
        Op::LOAD, 6, # c
        Op::STORE, 5, # b = c
        Op::LOAD, 7, # i
        Op::PUSH, 2, # 1,
        Op::ADD, # i + 1
        Op::STORE, 7, # i = i + 1
        Op::LOAD, 7, # i
        Op::LOAD, 0, # n
        Op::LTE, # i <= n
        Op::JNZ, 27, # jump back to loop start if i <= n is true

        Op::LOAD, 5, # b
        Op::RETURN # return b
      ], [
        "n", 0, 1, 2, "a", "b", "c", "i", "fib"
      ] of ValidType

      instructions = [
        Op::PUSH, 2,
        Op::PUSH, 0,
        Op::PROC, 1, 1,

        Op::PUSH, 3,
        Op::CALL, 1, 1,
        Op::EXIT
      ]

      vm = VM.new instructions, [
        fib, "fib", "n", 25
      ] of ValidType

      vm.run
      vm.stack.first.should eq(75025)

      vm = VM.new instructions, [
        fib, "fib", "n", 15
      ] of ValidType

      vm.run
      vm.stack.first.should eq(610)
    end
  end
end
