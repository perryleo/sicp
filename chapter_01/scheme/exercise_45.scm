;; The solution of exercise 1.45
;; We saw in section 1.3.3 that attempting to compute square roots by
;; naively finding a fixed point of y -> x/y does not converge, and that
;; this can be fixed by average damping. The same method works for finding
;; cube roots as fixed points of the average-damped y -> x / y ^ 2.
;;
;; Unfortunately, the process does not work for fourth roots -- a single
;; average damp is not enough to make a fixed-point search for y ->
;; x / y ^ 3 converge. On the other hand, if we average damp twice (i.e.,
;; use the average damp of the average damp of y -> x / y ^ 3) the fixed-
;; point search does (i.e., use the average damp of the average damp of y
;; converge. Do some experiments to determine how many average damps are
;; required to compute nth roots as a fixed-point search based upon
;; repeated average damping of y -> x / y ^ {n-1} . Use this to implement
;; a simple procedure for computing nth roots using fixed-point, average-
;; damp, and the repeated procedure of exercise 1.43. Assume that any
;; arithmetic operations you need are available as primitives.
;;
;; -------- (above from SICP)
;;

;; The tolerance used in the fixed-point procedure
(define tolerance 0.00001)

;; Fix-point computation procedure
(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))

;; Define average dumping of a function
(define (average-damp f)
  (lambda (x) (/ (+ x (f x)) 2)))

;; Define composition procedure
(define (compose f g)
  (lambda (x)
    (f (g x))))

;;
;; Repeated function. Actually this procedure is an iterative process. You
;; can compare the efficiency with the following procedure here:
;;
;;     (define (repeated f n)
;;       (define (iter counter result)
;;         (if (= counter n)
;;             result
;;             (iter (1+ counter) (f result))))
;;       (lambda (x)
;;         (iter 0 x)))
;;
;; But there exists an interesting thing:
;;
;;     (compose (repeated f (- n 1)) f) [ iterative process ]
;;     (compose f (repeated f (- n 1))) [ recursive process ]
;;
;; It is very easy to explain: the process type is determind by the
;; `compose` procedure.
;;

;; Repeated calling a function
(define (repeated f n)
  (lambda (x)
    (cond ((= n 0) x)
          ((= n 1) (f x))
          (else ((compose (repeated f (- n 1)) f) x)))))

;;
;; Compute the nth root of positive number a
;; Actually you can write this procedure without repeating `average-damp`.
;; Just simply replace this procedure with:
;;
;;     (define (nth-rt a n)
;;       (define (fun x)
;;         (/ (+ (* (- n 1) x)
;;               (- (/ (* 1.0 a)
;;                     (expt x (- n 1)))
;;                  x))
;;            n))
;;       (fixed-point fun 1.0))
;;
;; The efficiency is close to that of the following procedure. But notice
;; if you try to use the following procedure to compute (a ^ (1 / n)),
;; the parameter `n` should not be too big. Or the procedure will return
;; a wrong result.
;;
;; Actually the `expt` procedure or any functions in other languages to
;; compute float-power, doesn't use algorithm like this. The actual steps
;; are optimized with other techniques.
;;

(define (nth-root a n)
  ;; This `sqlg` procedure computes [log2 n]
  ;; Use this procedure to get the exact times of `average-damping`
  (define (sqlg m)
    (cond ((> (/ m 2) 1) (+ 1 (sqlg (/ m 2))))
          ((< (/ m 2) 1) 0)
          (else 1)))
  (define p (sqlg n))
  (define (fun x)
    (/ (* 1.0 a)
       (expt x (- n 1))))
  (fixed-point ((repeated average-damp p) fun) 1.0))

;;
;; There exists an important question: how many average-damping do we need
;; to make sure the newton sequence is convergent?
;;
;; Assumpt that we intend to compute the k th root of a positive real
;; number a (note it q = a ^ (1 / k)) and we use newton-method p times of
;; average-damping, which means:
;;
;;
;;     x_{n + 1} = (1 - 1 / 2 ^ p) * x_n + a / ((2 ^ p) * x_n ^ (k - 1))
;;     x_0 = 1.0
;;
;; From this formula, we get that:
;;
;;     x_{n + 1} - q          1
;;    --------------- = 1 - ----- * (1 + r + r ^ 2 + ... + r ^ (k - 1))
;;        x_n - q           2 ^ p
;;
;;    r = q / x_n
;;
;; Here we prove p = [log_2 k] is available.
;; If x_n < q, then r > 1 and
;;
;;     x_{n + 1} - q          1
;;    --------------- < 1 - ----- * k <= 0
;;        x_n - q           2 ^ p
;;
;; So we konw that x_{n + 1} > q. Thus we can only consider the other
;; situation where x_n > q (r < 1):
;;
;; From k <= 2 ^ {p + 1} - 1 we know that:
;;
;;     x_{n + 1} - q          1              2 ^ {p + 1} - 1          1
;;    --------------- > 1 - ----- * k >= 1 - --------------- = -1 + -----
;;        x_n - q           2 ^ p                 2 ^ p             2 ^ p
;;
;;     x_{n + 1} - q          1     r + ... + r ^ (k - 1)         1
;;    --------------- = 1 - ----- - --------------------- < 1 - -----
;;        x_n - q           2 ^ p          2 ^ p                2 ^ p
;;
;; From the two inequalities above we know:
;;
;;    |  x_{n + 1} - q  |         1
;;    | --------------- | < 1 - -----
;;    |     x_n - q     |       2 ^ p
;;
;; Then we know the newton method must be convergent.
;;

(define (main)
  (display "Load this file and use `nth-root` procedure.\n")
  (display "TEST: 167854676913 ^ (1 / 1879)\n")
  (display "TEST RESULT:    ")
  (display (nth-root 167854676913 1879))
  (newline)
  (display "COMPARED VALUE: ")
  (display (expt 167854676913 (/ 1.0 1879)))
  (newline))

(main)


