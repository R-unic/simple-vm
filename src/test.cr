require "./vm"
require "./opcodes"
require "./types"

vm = VM.new [
  Op::PUSH, 0,
  Op::PUSH, 1,
  Op::CONCAT,
  Op::ECHO,
  Op::END
], [
  "hello ", "world"
] of Types::ValidType
