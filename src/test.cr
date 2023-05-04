require "./vm"
require "./opcodes"
require "./types"
require "benchmark"

vm = VM.new [
  Op::PUSH, 0,
  Op::PUSH, 1,
  Op::CONCAT,
  Op::ECHO,
  Op::END
], [
  "hello ", "world"
] of Types::ValidType

Benchmark.bm do |x|
  x.report "msg = " { vm.run }
end
