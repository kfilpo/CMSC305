#lang racket
((lambda (x) (display (list x (list (quote quote) x)))) (quote (lambda (x) (display (list x (list (quote quote) x))))))