(module logic racket/base
	(require
		(only-in srfi/1 fold alist-delete)
		(only-in racket/set set->list)
		(only-in racket/function negate)
		racket/contract
		"../library/extension.scm"
		"../library/cache.scm"
		"../system/structure.scm"
		"../system/database.scm"
		"object.scm"
		"character.scm"
	)
	(provide (contract-out
		(protagonist? (-> any/c boolean?))
		(make-protagonist (-> list? any/c box?))
		(update-protagonist! (-> box? list? list?))
		(equipped? (-> protagonist? integer? (or/c symbol? false/c)))
		(attackers (-> box? list?))
		(attackers-add! (-> box? integer? void?))
		(attackers-delete! (-> box? integer? void?))
		(attackers-clear! (-> box? void?))
		(attackers-has? (-> box? integer? boolean?))
		(attackers-count (-> box? integer?))
	))

	(define protagonist (list
		(cons 'sp (negate =))
		(cons 'xp (negate =))
		(cons 'load (negate =))
		(cons 'pk-count (negate =))
		(cons 'pvp-count (negate =))

		(cons 'dead? (negate eq?))
		(cons 'clan-leader? (negate eq?))
		(cons 'dwarven-craft? (negate eq?))

		(cons 'character-id (negate =))
		(cons 'base-class-id (negate =))
		(cons 'max-load (negate =))
		(cons 'inventory-limit (negate =))
		(cons 'access-level (negate =))
		(cons 'physical-attack-power (negate =))
		(cons 'physical-defense (negate =))
		(cons 'magical-attack-power (negate =))
		(cons 'magical-defense (negate =))
		(cons 'accuracy (negate =))
		(cons 'evasion (negate =))
		(cons 'focus (negate =))

		(cons 'statements (negate alist-equal?))
		(cons 'equipment (negate alist-equal?))
		(cons 'attackers #f)
		(cons 'database #f)
	))

	(define (protagonist? object)
		(object-of-type? object 'protagonist)
	)

	(define (make-protagonist data db)
		(let* ((character (make-character data db)) (type (cons 'protagonist (ref character 'type))))
			(let ((xp (ref data 'xp)) (level (ref data 'level)))
				(box (append
					(list
						(cons 'type type)
						(cons 'level (or (db-level db xp) level))
						(cons 'attackers (make-cache-set 60 =)) ; Default aggro timeout.
						(cons 'database db)
					)
					(fold ; TODO extract xp
						(lambda (p r) (if (and p (assoc (car p) protagonist eq?)) (cons p r) r)) ; If field belongs to protagonist.
						(alist-except character eq? 'type 'level) ; TODO extract type
						data
					)
				))
			)
		)
	)

	(define (correct-level data db)
		(let* ((xp (ref data 'xp)) (level (and xp (db-level db xp))))
			(if level (cons (cons 'level level) (alist-delete 'level data eq?)) data)
		)
	)

	(define (update-protagonist object data)
		(let ((data (correct-level data (ref object 'database))))
			(let-values (((rest updated changes) (update-character object data)))
				(struct-update data protagonist rest updated changes)
			)
		)
	)
	(define (update-protagonist! object data)
		(let-values (((rest updated changes) (update-protagonist (unbox object) data)))
			(set-box! object (append rest updated))
			changes
		)
	)

	(define (equipped? me object-id)
		(fold (lambda (c p)
			(if (eq? object-id (cdr c)) (car c) p)
		) #f (ref me 'equipment))
	)

	(define (attackers protagonist)
		(set->list (cache-set-all (ref protagonist 'attackers)))
	)
	(define (attackers-add! protagonist object-id)
		(cache-set-add! (ref protagonist 'attackers) object-id)
	)
	(define (attackers-delete! protagonist object-id)
		(cache-set-delete! (ref protagonist 'attackers) object-id)
	)
	(define (attackers-clear! protagonist)
		(cache-set-clear! (ref protagonist 'attackers))
	)
	(define (attackers-has? protagonist object-id)
		(cache-set-has? (ref protagonist 'attackers) object-id)
	)
	(define (attackers-count protagonist)
		(cache-set-count (ref protagonist 'attackers))
	)
)
