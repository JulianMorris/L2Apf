(module extension racket/base
	(require srfi/1)
	(provide
		bind
		bind-head
		bind-tail
		bind-wrap
		any-is?
		every-is?
		alist-flip
		alist-ref
		string-starts?
		string-ends?
	)
	
	(define (bind f . args)
		(lambda ()
			(apply f args)
		)
	)
	
	(define (bind-head f . head)
		(lambda args
			(apply f (append head args))
		)
	)
	
	(define (bind-tail f . tail)
		(lambda args
			(apply f (append args tail))
		)
	)
	
	(define (bind-wrap f head tail)
		(lambda args
			(apply f (append head args tail))
		)
	)
	
	; Хотя бы один элемент списка l равны значению v, используя для сравнения предикат p
	(define (any-is? v l . t)
		(define p (if (null? t) equal? (car t)))
		(define (is i) (p v i))
		(apply any is l)
	)
	
	; Все элементы списка l равен значению v, используя для сравнения предикат p
	(define (every-is? v l . t)
		(define p (if (null? t) equal? (car t)))
		(define (is i) (p v i))
		(apply every is l)
	)
	
	(define (alist-flip l)
		(map (compose xcons car+cdr) l)
	)
	
	(define (alist-ref l k) ; TODO list key [predicate] => assf
		(cdr (assoc k l))
	)
	
	(define (string-starts? s t)
		(let ((ls (string-length s)) (lt (string-length t)))
			(and
				(>= ls lt)
				(string=? (substring s 0 lt) t)
			)
		)
	)
	
	(define (string-ends? s t)
		(let ((ls (string-length s)) (lt (string-length t)))
			(and
				(>= ls lt)
				(string=? (substring s (- ls lt)) t)
			)
		)
	)
	
	;(define-syntax letone (syntax-rules () (
	;	(letone id value body ...)
	;	((lambda (id) body ...) value)
	;)))
	
	; let-alist (((a b c) (k1 k2 k3) alist)) body
	
	; let-list (((a b c) list)) body ; receive ?
)
