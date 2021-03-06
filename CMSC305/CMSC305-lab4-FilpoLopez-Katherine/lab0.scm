#lang sicp

(define (double x) (+ x x))
(define (halve x) (quotient x 2))

(define (mult a b)
  (if (= b 0)
      0
      (+ a (mult a (- b 1)))))

(define (expression)   ((choose (list number binary unary))))
(define (binary)       (list (bin-op) (expression) (expression)))
(define (unary)        (list (uni-op) (expression)))
(define (bin-op)       (choose '(+ * / - expt)))
(define (uni-op)       (choose '(abs cos log sin tan)))
(define (number)       (random 10))

(define (choose lst)
  (list-ref lst (random (length lst))))

(display (expression))
(newline)
