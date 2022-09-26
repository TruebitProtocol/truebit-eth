(module
  (memory 1 1)
  (func (export "test")
    (memory.fill (i32.const 0xFF00) (i32.const 0x55) (i32.const 10))
    (memory.copy (i32.const 1000) (i32.const 0xff00) (i32.const 5))
  )
)
