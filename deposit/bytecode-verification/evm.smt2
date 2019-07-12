; (set-option :auto-config false)
; (set-option :smt.mbqi false)
; (set-option :smt.array.extensional false)

; int extra
(define-fun int_max ((x Int) (y Int)) Int (ite (< x y) y x))
(define-fun int_min ((x Int) (y Int)) Int (ite (< x y) x y))
(define-fun int_abs ((x Int)) Int (ite (< x 0) (- 0 x) x))

; bool to int
(define-fun smt_bool2int ((b Bool)) Int (ite b 1 0))

; IMap
(define-sort IMap () (Array Int Int))
(define-fun emptyIMap () IMap ((as const IMap) 0))

; ceil32
(define-fun ceil32 ((x Int)) Int ( * ( div ( + x 31 ) 32 ) 32 ) )
