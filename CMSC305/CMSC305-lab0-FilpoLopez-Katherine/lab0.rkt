#lang racket

(define (double a) (+ a a)) 
(define (halve a) (round (/ a 2))) 

(define (mult a b)
  (if (= b 0)
      0
      (+ a (mult a (- b 1)))))
(define (mult2 a b)
  (if (> b a )
      (mult b a)
      (mult a b)))


(define (binaryExpression)  (list (operator) (expression) (expression)))
(define (unary)       (list (choose '(sin cos tan)) (number)))
(define (operator)    (choose '(+ * / -)))
(define (number)      (random 10))

(define (choose lst)
  (list-ref lst (random (length lst))))

(define (expression)
  (define t (random 3))
  (if (= t 0)
      (number)
      (if (= t 1)
         (binaryExpression)
          (unary)))
  )
