require "./vm"
require "./opcodes"
require "./types"

# def fibonacci(n)
#   if n < 2
#     return n
#   else
#     return fibonacci(n - 1) + fibonacci(n - 2)
#   end
# end

fib = VM.new [
  Op::LOAD, 0,
  Op::ECHO,
  Op::END
], [
  "n",
] of Types::ValidType

vm = VM.new [
  Op::PUSH, 2,
  Op::PUSH, 0,
  Op::PROC, 1, 1,

  Op::PUSH, 3,
  Op::CALL, 1, 1,
  Op::END
], [
  fib, "fib", "n", 5_i64
] of Types::ValidType

vm.run
