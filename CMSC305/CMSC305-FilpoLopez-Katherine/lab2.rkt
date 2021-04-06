#lang racket
;;(evaluate (lex "18 2 + 4 /")) →  '(5)

(define (lex string)
    (string-split string)
    ;;(map (lambda (x) (check x) (string-split string)))
          ;; (string-split string)) string)           
)

(define (numeric? s) (string->number s)) ;;put x here?

(define (check x)
  (if (not (= (numeric? x) #f))
      (numeric? x)
      (x)
      )
  )

(define stack ' ()) ;;now its a global variable------ define vs creating a variable?
(define (empty-stack? list)
  (if (null? list)
   (error "The stack is empty")
   #t)
  )
(define (push-stack item) (set! stack (cons item stack)) )
(define (top-stack) (display (car stack)) (newline)) ;
(define (pop-stack) (display (car stack)) (newline) (set! stack (cdr stack)))

;(push-stack 3)
;(push-stack 4)
;(push-stack 5)
;(push-stack "/")
;(top-stack)
;(push-stack 7)
;(pop-stack)
;(display stack)

(define (evaluate lst)
  (if (null? lst)
      (error "cannot evaluate an empty stack")      
      (for ([i (length lst)]) (push-stack (list-ref lst i))) 
        ;;((number? lst) )
        ((equal? (list-ref lst i) "+") (add pop-stack pop-stack))
        )
  (display stack))
;;(evaluate (lex "18 2 + 4 /"))
(evaluate '(18 2 "+" 4 "/"))

(define (display2) print stack) ;;if stack is empty?
(define (add x y) (+ x y))
(define (sub x y) (- x y))
(define (div x y) (/ x y))
(define (mul x y) (* x y))
(define (expon x y) (expt y x))
(define (sinfun x) (sin x))
(define (cosfun x) (cos x))
(define (tanfun x) (tan x))
(define (dotS) (display stack))
(define (dot) (pop-stack))
(define (dup) (push-stack(top-stack)))
;;(define (swap) ())
(define (drop) (pop-stack))
(define (drop2) (pop-stack) (pop-stack))
;;(define (over) )
;;(define (rot) )
;;(define (nip) )
;;(define (tuck) )

