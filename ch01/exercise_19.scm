;; The solution of exercise 1.19
;; There is a clever algorithm for computing the Fibonacci numbers in a
;; logarithmic number of steps. Recall the transformation of the state
;; variables a and b in the `fib-iter` process of section 1.2.2:
;;
;;     a <- a + b,   and   b <- a
;;
;; Call this transformation T, and observe that applying T over and over
;; again n times, starting with 1 and 0, produces the pair Fib(n + 1) and
;; Fib(n). In other words, the Fibonacci numbers are produced by applying
;; T ^ n, the n th power of the transformation T, starting with the pair
;; (1, 0). Now consider T to be the special case of p = 0 and q = 1 in a
;; family of transformations T_{pq}, where T_{pq} transforms the pair
;; (a, b) according to
;;
;;     a <- b * q + a * q + a * p,   and   b <- b * p + a * q
;;
;; Show that if we apply such a transformation T_{pq} twice, the effect is
;; the same as using a single transformation T_{p'q'} of the same form, and
;; compute p' and q' in terms of p and q. This gives us an explicit way to
;; square these transformations, and thus we can compute T ^ n using
;; successive squaring, as in the `fast-expt` procedure.
;;
;; -------- (above from SICP)
;;
;; Actually we can describe the basic thought in mathematical languages.
;; Assume we have a constant matrix:
;;
;;         / 1  1 \                          / 1 \
;;     T = |      |  , and init vector:  v = |   |
;;         \ 1  0 /                          \ 0 /
;;
;; Then, when n >= 2, obviously we have:
;;
;;     /   Fib(n)   \   / 1  1 \ / Fib(n - 1) \
;;     |            | = |      | |            | = ... T ^ (n - 1) * v
;;     \ Fib(n - 1) /   \ 1  0 / \ Fib(n - 2) /
;;
;; Generally, we set matrix:
;;
;;              / p + q  q \
;;     T_{pq} = |          |  , then T = T_{01}
;;              \   q    p /
;;
;;                  / p + q  q \ / p + q  q \
;;     T_{pq} ^ 2 = |          | |          | = |
;;                  \   q    p / \   q    p /
;;
;;                  / (p + q) ^ 2 + q ^ 2   (p + q) * q + q * p \
;;                = |                                           |
;;                  \ (p + q) * q + q * p       q ^ 2 + p ^ 2   /
;;
;;                  / p' + q'  q' \          / p' \   /   q ^ 2 + p ^ 2   \
;;                = |             | ,  where |    | = |                   |
;;                  \    q'    p' /          \ q' /   \ q ^ 2 + q * p * 2 /
;;
;; Now we realize the algorithm in scheme.
;;

(define (fib n)
  (fib-iter 1 0 0 1 n))

(define (fib-iter a b p q count)
  (cond ((= count 0) b)
        ((= 0 (modulo count 2))
         (fib-iter a
                   b
                   (+ (* q q) (* p p))
                   (+ (* q q) (* 2 p q))
                   (/ count 2)))
        (else (fib-iter (+ (* b q) (* a q) (* a p))
                        (+ (* b p) (* a q))
                        p
                        q
                        (- count 1)))))

;; List the Fibonacci numbers
(define (display-iter counter max-count)
  (if (<= counter max-count)
      (begin
        (display "fibonacci(") (display counter) (display ") \t")
        (display (fib counter))
        (newline)
        (display-iter (+ counter 1) max-count))))

;;
;; Use trace to see the calls. For example, trace (fib 60):
;; trace: (fib 60)
;; trace: (fib-iter 1 0 0 1 60)
;; trace: (fib-iter 1 0 1 1 30)
;; trace: (fib-iter 1 0 2 3 15)
;; trace: (fib-iter 5 3 2 3 14)
;; trace: (fib-iter 5 3 13 21 7)
;; trace: (fib-iter 233 144 13 21 6)
;; trace: (fib-iter 233 144 610 987 3)
;; trace: (fib-iter 514229 317811 610 987 2)
;; trace: (fib-iter 514229 317811 1346269 2178309 1)
;; trace: (fib-iter 2504730781961 1548008755920 1346269 2178309 0)
;; trace: 1548008755920
;;

(define (main)
  (display "Compute Fibonacci number f(n).\nInput n: ")
  (let ((n (read)))
    (display "[Fibonacci numbers]\n")
    (display-iter 1 n)))

(main)


