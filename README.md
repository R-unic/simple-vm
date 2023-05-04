# simple-vm

greater than
```rb
vm = VM.new [ # 10 > 20
  Op::PUSH, 0,
  Op::PUSH, 1,
  Op::GT,
  Op::ECHO,
  Op::END
], [10, 20]
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
  Op::END
], [14, 6, 12, 3]
vm.run # => -16.0
```

closures
```rb
do_something = VM.new [ # fn do_something(b) { echo a; echo b; }
  Op::LOAD, 0,
  Op::ECHO,
  Op::LOAD, 1,
  Op::ECHO,
  Op::END
], ["a", "b"] of Types::ValidType

vm = VM.new [ # a = "something" (define do_something) do_something("some value")
  Op::PUSH, 0, # "something"
  Op::STORE, 1, # a = "something"

  # start of function def, first values are arguments. second to last value is the function body (as it's own VM).
  Op::PUSH, 5, # "b"
  Op::PUSH, 3, # VM<do_something>
  Op::PROC, 2, 1, # create fn with name at address 2 ("func"), and 1 argument ("b")

  Op::PUSH, 4, # "some value"
  Op::CALL, 2, 1, # lookup and call closure name at address 2 with 1 argument ("some value")
  Op::END
], ["something", "a", "func", do_something, "some value", "b"] of Types::ValidType

vm.run # => something some value
```

fibonacci sequence
```rb
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
  fib, "fib", "n", 25
] of Types::ValidType

vm.run # 75025
```
