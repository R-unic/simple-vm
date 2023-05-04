require "./vm"
require "./opcodes"
require "./typechecker"; include Types;

vm = VM.new [
  Op::PUSH, 0,
  Op::PUSH, 1,
  Op::CONCAT,
  Op::ECHO,
  Op::END
], [
  "hello ", "world"
] of ValidType

vm.run
