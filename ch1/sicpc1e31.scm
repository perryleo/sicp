;; The solution of exercise 1.31
;; [a] The `sum` procedure is only the simplest of a vast number of similar
;;     abstractions that can be captured as higher-order procedures. Write
;;     an analogous procedure called `product` that returns the product of
;;     the values of a function at points over a given range. Show how to
;;     define factorial in terms of product. Also use `product` to compute
;;     approximations to using the Wallis formula:
;;
;;     PI     2 * 4 * 4 * 6 * 6 * 8 * 8 * 10 * ...
;;    ---- = --------------------------------------
;;     4      3 * 3 * 5 * 5 * 7 * 7 * 9 * 9  * ...
;;
;; [b] If your product procedure generates a recursive process, write one
;;     that generates an iterative process. If it generates an iterative
;;     process, write one that generates a recursive process.
;;
;; -------- (above from SICP)
;;

;; The square procedure
(define (square x) (* x x))

;; New abstract product procedure (iterative process)
(define (product term a next b)
  (define (iter m result)
    (if (> m b)
        result
        (iter (next m) (* result (term m)))))
  (iter a 1))

;; New abstract product procedure (recursive process)
(define (product-rec term a next b)
  (if (> a b)
      1
      (* (term a)
         (product-rec term (next a) next b))))

;; The procedure to compute the value of PI approximately using the famous
;; John-Wallis formula. (This is an iterative process)
(define (wallis-pi n)
  ;; Here we convert the exact rational number to an inexact float number.
  ;; Because we do not need the computer to compute the exact rational
  ;; approximate value. Just float number is Ok, and it can increase the
  ;; computing speed at the same time.
  (define (term m)
    (/ (- (square m) 1.0) (square m)))
  (* 4.0 (product term
                  3
                  (lambda (x) (+ x 2))
                  (+ 1 (* 2 n)))))

;; The procedure to compute the value of PI approximately using the famous
;; John-Wallis formula. (This is an recursive process)
(define (wallis-pi-rec n)
  (define (term m)
    (/ (- (square m) 1.0) (square m)))
  (* 4.0 (product-rec term
                      3
                      (lambda (x) (+ x 2))
                      (+ 1 (* 2 n)))))

;;
;; Actually not every implementation has the procedure `runtime`. You can
;; use alternatives for different interpreter:
;;
;; [1] guile:
;;     (define (runtime) (tms:clock (times)))
;;
;; [2] racket
;;     (define (runtime) (current-milliseconds))
;;
;; In mit-scheme, use (runtime) directly.
;;
(define (runtime) (tms:clock (times)))

;; Compute the runtime of @wallis-pi and @wallis-pi-rec
(define (wallis-runtime func n)
  (define (clause-runtime start-time)
    (display "PI: ")
    (display (func n))
    (newline)
    (display "runtime: ")
    (display (- (runtime) start-time))
    (newline))
  (clause-runtime (runtime)))

(define (main)
  (display "Load this file and use `wallis-pi` procedure.\n")
  (display "We compute PI using wallis formula with 1000000 terms.\n")
  (display "Default: iterative process.\n")
  (display "Use `wallis-pi-rec` procedure for recursive process.\n")
  (display "PI = ")
  (display (wallis-pi 1000000))
  (newline))

(main)

