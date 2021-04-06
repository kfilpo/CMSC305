#lang racket
(require eopl)

(define the-lexical-spec
  '((whitespace (whitespace) skip)
    (number ("-" digit (arbno digit)) number)
    (mul-op ((or "*" "/")) symbol)
    (add-op ((or "+" "-")) symbol)
    (number (digit (arbno digit)) number)))

(define the-grammar
  '((a-expr ;:==
        (a-term (arbno add-op a-term))       binop)
    (a-term ;:==
        (a-factor (arbno mul-op a-factor))   binop)
    (a-factor ;:==
         (number)                            number)
    (a-factor ;:==
         ("(" a-expr ")")                    factor)))

(define-datatype infix infix?
  (binop
    (left infix?)
    (operators (list-of symbol?))
    (right (list-of infix?)))
  (factor
    (value infix?))
  (number
    (value integer?)))

(define just-scan
    (sllgen:make-string-scanner the-lexical-spec the-grammar))

(define scan&parse
  (sllgen:make-string-parser the-lexical-spec the-grammar))

(display (just-scan "2 + 3 * 4"))
(newline)
(display (scan&parse "2 + 3 * 4"))
(newline)

;;((number 2 1) (add-op + 1) (number 3 1) (mul-op * 1) (number 4 1))
;;#(struct:binop #(struct:binop #(struct:number 2) () ()) (+) 
;;(#(struct:binop #(struct:number 3) (*) (#(struct:number 4)))))

(define my-eval
  (let ((ns (make-base-namespace)))
    (lambda (expr) (eval expr ns))))

(define (value-of exp)
  (cases infix exp
    (binop (first ops rest)
      (apply-ops (value-of  first) ops (map value-of rest)))
    (number (val)
      val)
    (factor (expr)
      (value-of  expr))))

(define (apply-ops first ops rest)
  (if (null? ops)
      first
      (apply-ops ((my-eval (car ops)) first (car rest))
                 (cdr ops)
                 (cdr rest))))

(display (value-of (scan&parse "3 / -6")))
(newline)

;;need a walker that traverses the tree
