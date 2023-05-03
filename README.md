# simple-vm

greater than
```ruby
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
```ruby
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
