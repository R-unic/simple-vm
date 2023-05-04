require "./spec_helper"

describe VM do
  describe "#run" do
    it "should run hello world" do
      vm = VM.new [
        Op::PUSH, 0,
        Op::PUSH, 1,
        Op::CONCAT,
        Op::END
      ], ["hello ", "world"] of ValidType

      vm.run
      vm.stack.first.should eq("hello world")
    end

    it "should be able to define & load variables" do
      vm = VM.new [
        Op::PUSH, 0,
        Op::STORE, 1,
        Op::LOAD, 1,
        Op::END
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
        Op::END
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
        Op::END
      ], [6, 14, 6, 12, 3, 17] of ValidType

      vm.run
      vm.stack.first.should eq(-2.5454545454545454)
    end

    it "should run fibonacci sequence" do
      fib = VM.new [
        Op::LOAD, 0,
        Op::PUSH, 1,
        Op::LT,

        Op::JZ, 10, # if false jump to 10 (noop)
        Op::LOAD, 0, # n
        Op::RETURN,

        Op::NOOP, # else (this is unnecessary, just for readability)
        Op::LOAD, 0, # n
        Op::PUSH, 2, # 1
        Op::SUB, # n - 1
        Op::CALL, 3, 1, # fib(n - 1)

        Op::LOAD, 0, # n
        Op::PUSH, 1, # 2
        Op::SUB, # n - 2
        Op::CALL, 3, 1, # fib(n - 2)
        Op::ADD, # fib(n - 1) + fib(n - 2)

        Op::RETURN
      ], [
        "n", 2, 1, "fib"
      ] of ValidType

      instructions = [
        Op::PUSH, 2,
        Op::PUSH, 0,
        Op::PROC, 1, 1,

        Op::PUSH, 3,
        Op::CALL, 1, 1,
        Op::END
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
