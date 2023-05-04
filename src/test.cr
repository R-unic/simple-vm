require "./vm"
require "./opcodes"
require "./types"
require "benchmark"

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
  "n", 2_i64, 1_i64, "fib"
] of Types::ValidType

vm = VM.new [
  Op::PUSH, 2,
  Op::PUSH, 0,
  Op::PROC, 1, 1,

  Op::PUSH, 3,
  Op::CALL, 1, 1,
  Op::ECHO,
  Op::END
], [
  fib, "fib", "n", 25_i64
] of Types::ValidType

Benchmark.bm do |x|
  x.report "fib 25 = " { vm.run }
end
