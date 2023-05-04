# simple-vm

greater than
```rb
vm = VM.new [ # 10 > 20
  Op::PUSH, 0,
  Op::PUSH, 1,
  Op::GT,
  Op::ECHO,
  Op::HALT
], [10_f32, 20_f32]
vm.run # => 0.0 (false)
```

simple arithmetic
```rb
vm = VM.new [ # 14 + 6 - 12 * 3
  Op::PUSH, 0,
  Op::PUSH, 1,
  Op::PUSH, 2,
  Op::PUSH, 3,
  Op::MUL,
  Op::SUB,
  Op::ADD,
  Op::ECHO,
  Op::HALT
], [14_f32, 6_f32, 12_f32, 3_f32]
vm.run # => -16.0
```

closures
```rb
do_something = VM.new [ # fn do_something(b) { echo a; echo b; }
  Op::LOAD, 0,
  Op::ECHO,
  Op::LOAD, 1,
  Op::ECHO,
  Op::HALT
], ["a", "b"] of Types::ValidType

vm = VM.new [ # a = "something" (define do_something) do_something("some value")
  Op::PUSH, 0, # "something"
  Op::STORE, 1, # a = "something"

  # start of function def, first values are arguments. second to last value is the function body (as it's own VM).
  Op::PUSH, 5, # "b"
  Op::PUSH, 3, # VM<do_something>
  Op::PROC, 2, 1, # create fn with name at address 2 ("func"), and 1 argument

  Op::PUSH, 4, # "some value"
  Op::CALL, 1, # call last closure in the stack with 1 argument, "some value".
  Op::HALT
], ["something", "a", "func", do_something, "some value", "b"] of Types::ValidType

vm.run # => something some value
```
