
(module
    (memory 1234)
    (type (func (param i32 i32 i32)))
    ;; fill
    (func (type 0) (local i32)
      loop
        local.get 3
        local.get 2
        i32.eq
        br_if 1
        local.get 3
        local.get 0
        i32.add
        local.get 1
        i32.store8
        local.get 3
        i32.const 1
        i32.add
        local.set 3
        br 0
      end
    )
    ;; copy
    (func (type 0) (local i32)
      loop
        local.get 3
        local.get 2
        i32.eq
        br_if 1 ;; check if at end
        local.get 3
        local.get 0
        i32.add ;; find destination
        local.get 3
        local.get 1
        i32.add ;; find source
        i32.load8_u
        i32.store8
        local.get 3
        i32.const 1
        i32.add
        local.set 3
        br 0
      end
    )
)
