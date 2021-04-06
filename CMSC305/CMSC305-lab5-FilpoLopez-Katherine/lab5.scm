#lang racket
(require eopl)

(define the-lexical-spec
  '((whitespace (whitespace) skip)
    (number ("-" digit (arbno digit)) number)
    (number (digit (arbno digit) "." digit (arbno digit)) number)
    (number (digit (arbno digit) (or "e" "E") (or "-" "+") digit (arbno digit)) number)
    (number (digit (arbno digit)) number)
    (string (#\" (arbno (not #\")) #\") string)
    ;;(string ("\""
             ;;(or ((not #\") (not #\\) (not #\/) (not #\b)
                 ;;(not #\f) (not #\n) (not #\r) (not #\t))
                 ;;any) "\"") string)
;    (String ("\\"" any "\\"") String)
;    (String ("\"" "\\" any "\"") String)
;    (String ("\\/" any) String)
;    (String ("\\b" any) String)
;    (String ("\\f" any) String)
;    (String ("\\n" any) String)
;    (String ("\\r" any) String)
;    (String ("\\t" any) String)
    
    ))

(define the-grammar
  '((json  ("[" (separated-list json ",") "]")  nlist) ;;separated-list allows there to not be a comma at the end of the list
    (json  (number)                             numval)
    (json  (string) str)
    (json  ("{" (separated-list string ":" json ",") "}") obj)
    (json ("true") True)
    (json ("false") False)
    (json ("null") Null)
    ))

(define-datatype json json?
  (nlist (numbers (list-of json?)))
  (numval (num number?))
  (str (st string?))
  (obj (keys (list-of string?)) (values (list-of json?)))
  (True)
  (False)
  (Null))

(define just-scan
    (sllgen:make-string-scanner the-lexical-spec the-grammar))

(define scan&parse
  (sllgen:make-string-parser the-lexical-spec the-grammar))

(display (just-scan "1"))
(newline)
(display (just-scan "[2, 3]"))
(newline)
(display (just-scan "[2,3,4]"))
(newline)
(display (scan&parse "[1, [2, [3, 4]]]"))
(newline)
(display (scan&parse "\"Hello\""))
(newline)
(display (scan&parse "{ \"Olivia\" : 19}"))
(newline)
(display (scan&parse "null"))
(newline)
(display (scan&parse "{\"ages\": [1,52,-53]}"))
(newline)




(define (json->sexp exp)
  (cases json exp 
    (nlist (numbers) (map json->sexp numbers))
    (numval (num) num)
    (str (St) St)
    (obj (keys values) (map (lambda (k y) (cons k (json->sexp y))) keys values))
    (True () #t)
    (False () #f)
    (Null () '())
    (else (error "not proper json"))))

(display (json->sexp (scan&parse "1")))
(newline)
(display (json->sexp (scan&parse "[2,3,4]")))
(newline)
(display (json->sexp (scan&parse "[1, [2, [3, 4]]]")))
(newline)
(display (json->sexp (scan&parse "\"Hello\"")))
(newline)
(display (json->sexp (scan&parse "true")))
(newline)
(display (json->sexp (scan&parse "false")))
(newline)
(display (json->sexp (scan&parse "null")))
(newline)
(display (json->sexp (scan&parse "{ \"Olivia\" : \"19\"}")))
(newline)
(display (json->sexp (scan&parse "{\"ages\": [1,52,-53]}")))
(newline)

(define t0 "{\"program\": \"CMSC\", \"class\": 305, \"days\": [\"Tue\", \"Thu\", \"Fri\"]}")
(display (json->sexp (scan&parse t0)))
(newline)


(define (json->XML-exp exp)
  (cases json exp 
    (nlist (numbers) (map json->XML-exp numbers))
    (numval (num) num)
    (str (St) St)
    (obj (keys values) (map (lambda (k y) (~s"<"k">" (json->XML-exp y) #\\ "<"k">")) keys values))
    (True () true)
    (False () false)
    (Null () '())
    (else (error "not proper json"))))

(display (json->XML-exp (scan&parse "1")))
(newline)
(display (json->XML-exp (scan&parse "{\"ages\": [1,52,-53]}")))
(newline)