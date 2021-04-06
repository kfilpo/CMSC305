#lang racket

(define the-empty-environment '())

(define (lookup-variable-value var env)
  (define (env-loop env)
      (cond ((not (hash-has-key? (car env) var))
             (env-loop 
              (enclosing-environment env)))
            ((hash-has-key? (car env) var)
              (hash-ref (car env) var))))
             ;(car vals))
            ;(else (scan (cdr vars) 
                        ;(cdr vals)))))
    (if (eq? env the-empty-environment)
        (error  "Unbound variable" var)
        ;(let ((frame (first-frame env))
         ; scan (frame-variables frame)
                ;(frame-values frame)))))
  (env-loop env)))



(define (set-variable-value! var val env)
  (define (env-loop env)
    ;(define (scan vars vals)
      (cond ((not (hash-has-key? (car env) var))
             (env-loop 
              (enclosing-environment env)))
            ((hash-has-key? (car env) var)
             (hash-set! (car env) var val))))
            ;(else (scan (cdr vars) 
                        ;(cdr vals))))
    (if (eq? env the-empty-environment)
        (error "Unbound variable: SET!" var)
        ;(let ((frame (first-frame env)))
          ;(scan (frame-variables frame)
                ;(frame-values frame)))))
  (env-loop env)))

(define (define-variable! var val env)
  (hash-set! (car env) var val))
  ;(let ((frame (first-frame env)))
   ; (define (scan vars vals)
    ;  (cond ((null? vars)
     ;        (add-binding-to-frame! 
      ;        var val frame))
       ;     ((eq? var (car vars))
        ;     (set-car! vals val))
         ;   (else (scan (cdr vars) 
          ;              (cdr vals)))))
    ;(scan (frame-variables frame)
     ;     (frame-values frame)))

(define (extend-environment vars vals base-env)
  (if (= (length vars) (length vals))
      (cons (make-frame vars vals) base-env)
      (if (< (length vars) (length vals))
          (error "Too many arguments supplied" 
                 vars 
                 vals)
          (error "Too few arguments supplied" 
                 vars 
                 vals))))

(define (make-frame variables values) ;;loop through lists and make a hash map
  (let ((x (make-hash))) 
  (define (loop-through x variables values)
    (unless (null? variables)
        (list (hash-set! x (car variables) (car values))
              (loop-through x (cdr variables) (cdr variables)))))
  (loop-through x variables values)
  x))
  
  ;(cons variables values))
;(define (frame-variables frame) (car frame))
;(define (frame-values frame) (cdr frame))
;(define (add-binding-to-frame! var val frame)
  ;(set-car! frame (cons var (car frame)))
  ;(set-cdr! frame (cons val (cdr frame))))

(define (let-new varList expList body)
  ((lambda (varList) body)
   expList))
  


(define (enclosing-environment env) (cdr env))
(define (first-frame env) (car env))

(define (make-procedure parameters body env)
  (list 'procedure parameters body env))
(define (compound-procedure? p)
  (tagged-list? p 'procedure))
(define (procedure-parameters p) (cadr p))
(define (procedure-body p) (caddr p))
(define (procedure-environment p) (cadddr p))

(define (true? x)
 (not (eq? x #f)))

(define (false? x)
  (eq? x #f))

(define (cond? exp) 
  (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) 
  (car clause))
(define (cond-actions clause) 
  (cdr clause))
(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))
(define (expand-clauses clauses)
  (if (null? clauses)
      'false     ; no else clause
      (let ((first (car clauses))
            (rest (cdr clauses)))
        (if (cond-else-clause? first)
            (if (null? rest)
                (sequence->exp 
                 (cond-actions first))
                (error "ELSE clause isn't 
                        last: COND->IF"
                       clauses))
            (make-if (cond-predicate first)
                     (sequence->exp 
                      (cond-actions first))
                     (expand-clauses 
                      rest))))))

(define (application? exp) (pair? exp))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))


(define (sequence->exp seq)
  (cond ((null? seq) seq)
        ((last-exp? seq) (first-exp seq))
        (else (make-begin seq))))

(define (make-begin seq) (cons 'begin seq))

(define (begin? exp) 
  (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))

(define (make-if predicate 
                 consequent 
                 alternative)
  (list 'if 
        predicate 
        consequent 
        alternative))


(define (if? exp) (tagged-list? exp 'if))
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
  (if (not (null? (cdddr exp)))
      (cadddr exp)
      'false))

(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

(define (lambda? exp) 
  (tagged-list? exp 'lambda))
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))

(define (definition? exp)
  (tagged-list? exp 'define))

(define (definition-variable exp)
  (if (symbol? (cadr exp))
      (cadr exp)
      (caadr exp)))

(define (definition-value exp)
  (if (symbol? (cadr exp))
      (caddr exp)
      (make-lambda 
       (cdadr exp)   ; formal parameters
       (cddr exp)))) ; body

(define (assignment? exp)
  (tagged-list? exp 'set!))

(define (assignment-variable exp) 
  (cadr exp))

(define (assignment-value exp) (caddr exp))

(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      'false))

(define (quoted? exp)
  (tagged-list? exp 'quote))

(define (text-of-quotation exp)
  (cadr exp))


(define (variable? exp) (symbol? exp))

(define (self-evaluating? exp)
  (cond ((number? exp) #t)
        ((string? exp) #t)
        (else #f)))


(define (eval-definition exp env)
  (define-variable! 
    (definition-variable exp)
    (eval-sicp (definition-value exp) env)
    env)
  'ok)

(define (eval-assignment exp env)
  (set-variable-value! 
   (assignment-variable exp)
   (eval-sicp (assignment-value exp) env)
   env)
  'ok)

(define (eval-sequence exps env)
  (cond ((last-exp? exps) 
         (eval-sicp (first-exp exps) env))
        (else 
         (eval-sicp (first-exp exps) env)
         (eval-sequence (rest-exps exps) 
                        env))))

(define (eval-if exp env)
  (if (true? (eval-sicp (if-predicate exp) env))
      (eval-sicp (if-consequent exp) env)
      (eval-sicp (if-alternative exp) env)))

(define (list-of-values exps env)
  (if (no-operands? exps)
      '()
      (cons (eval-sicp (first-operand exps) env)
            (list-of-values 
             (rest-operands exps) 
             env))))




(define (eval-and exp env)
  (if (null? (car exp))
      #t
      (if (eval (car exp) env)
          (eval-and (cdr exp) env)
          #f)))

(define (eval-or exp env)
  (if (null? (car exp))
      #f
      (if (eval (car exp) env)
          #t
          (eval-or (cdr exp) env))))

(define (and? exp)
  (equal? 'and (car exp)))

(define (or? exp)
  (equal? 'or (car exp)))

(define (let? exp)
  (equal? 'let (car exp)))

(define (eval-let exp)
  ((lambda (varL expL body)
     (let-new varL expL body))
   (define (loop-let exp)
    (cond ((null? exp)
        0)
        ((variable? (car exp))
         (cons varL (car exp))
         (loop-let (cdr exp)))
        ((exp? (car exp))
         (cons expL (car exp))
         (loop-let (cdr exp)))))
     (loop-let exp)))
          




(define (apply-sicp procedure arguments)
  (display (format "applying (~s ~s) \n" exp arguments))
  (cond ((primitive-procedure? procedure)
         (apply-primitive-procedure 
          procedure 
          arguments))
        ((compound-procedure? procedure)
         (eval-sequence
           (procedure-body procedure)
           (extend-environment
             (procedure-parameters 
              procedure)
             arguments
             (procedure-environment 
              procedure))))
        (else
         (error "Unknown procedure 
                 type: APPLY" 
                procedure))))

(define (eval-sicp exp env)
  (let ((r 
	 (cond ((self-evaluating? exp) 
		exp)
	       ((variable? exp) 
		(lookup-variable-value exp env))
	       ((quoted? exp) 
		(text-of-quotation exp))
	       ((assignment? exp) 
		(eval-assignment exp env))
	       ((definition? exp) 
		(eval-definition exp env))
	       ((if? exp) 
		(eval-if exp env)) ;;;special form of and short circulting
	       ((lambda? exp)
		(make-procedure 
		 (lambda-parameters exp)
		 (lambda-body exp)
		 env))
               ((let? exp)
                (eval-let))
	       ((begin? exp)
		(eval-sequence 
		 (begin-actions exp) 
		 env))
	       ((cond? exp) 
		(eval-sicp (cond->if exp) env))
	       ((application? exp)
		(apply-sicp (eval-sicp (operator exp) env)
			  (list-of-values 
			   (operands exp) 
			   env)))
               ((and? exp) (eval-and exp env))
               ((or? exp) (eval-or exp env))
	       (else
		(error "Unknown expression 
                 type: EVAL" exp)))))
    ;;(display (format "evaling ~s\n" exp))
    r))

(define (primitive-procedure? proc)
  (tagged-list? proc 'primitive))

(define (primitive-implementation proc) 
  (cadr proc))

(define primitive-procedures
  (list (list 'car car)
        (list 'cdr cdr)
        (list 'cons cons)
        (list '+ +)
        (list '- -)
        (list '/ /)
        (list '* *)
        (list '< <)
        (list '> >)
        (list '<= <=)
        (list '>= >=)
        (list 'cos cos)
        (list 'sin sin)
        (list 'expt expt)
        (list 'abs abs)
        (list 'log log)
        (list 'list list)
        (list 'list-ref list-ref)
        (list 'random random)
        (list 'length length)
        (list 'newline newline)
        (list 'display display)
        (list 'null? null?)))

(define (primitive-procedure-names)
  (map car primitive-procedures))

(define (primitive-procedure-objects)
  (map (lambda (proc) 
         (list 'primitive (cadr proc)))
       primitive-procedures))

(define (apply-primitive-procedure proc args)
  (display (format "applying ~s to ~s\n" proc args))
  (apply
   (primitive-implementation proc) args))

(define (setup-environment)
  (let ((initial-env
         (extend-environment 
          (primitive-procedure-names)
          (primitive-procedure-objects)
          the-empty-environment)))
    (define-variable! 'true #t initial-env)
    (define-variable! 'false #f initial-env)
    initial-env))

(define the-global-environment 
  (setup-environment))

(define input-prompt  ";;; M-Eval input:")
(define output-prompt ";;; M-Eval value:")

(define (prompt-for-input string)
  (newline) (newline) 
  (display string) (newline))

(define (announce-output string)
  (newline) (display string) (newline))

(define (user-print object)
  (if (compound-procedure? object)
      (display 
       (list 'compound-procedure
             (procedure-parameters object)
             (procedure-body object)
             '<procedure-env>))
      (display object)))

(define (driver-loop)
  (prompt-for-input input-prompt)
  (let ((input (read)))
    (let ((output 
           (eval-sicp input 
                 the-global-environment)))
      (announce-output output-prompt)
      (user-print output)))
  (driver-loop))

(driver-loop)

(eval '(- 2 3) (+ -5 (cos (/ -5 (expt 7 9)))))
