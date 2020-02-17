(module logic racket/base
	(require
		(rename-in racket/contract (any all/c))
		srfi/1
		"../library/geometry.scm"
		"../system/structure.scm"
		"map.scm"
		"object.scm"
	)
	(provide (contract-out
		(creature? (any/c . -> . boolean?))
		(create-creature (list? . -> . list?))
		(update-creature (list? list? . -> . list?))
		(update-creature! (box? list? . -> . void?))
		(get-angle (creature? . -> . rational?))
		(get-position (creature? . -> . point/3d?))
		(moving? (creature? . -> . boolean?))
		(casting? (creature? . -> . boolean?))
		(creatures-angle (creature? creature? . -> . (or/c rational? false/c)))
		(creatures-distance (creature? creature? . -> . integer?))
	))

	(define (creature? object)
		(if (and object (member 'creature (@: object 'type))) #t #f)
	)

	(define (create-creature struct) ; TODO make-creature
		(let ((object (create-object struct)))
			(let ((type (cons 'creature (@: object 'type))))
				(append (alist-delete 'type object) (list
					(cons 'type type)

					(cons 'name (@: struct 'name))
					(cons 'title (@: struct 'title))

					(cons 'target-id #f)

					(cons 'hp (@: struct 'hp))
					(cons 'mp (@: struct 'mp))
					(cons 'max-hp (@: struct 'max-hp))
					(cons 'max-mp (@: struct 'max-mp))

					(cons 'sitting? (@: struct 'sitting?))
					(cons 'running? (@: struct 'running?))
					(cons 'casting? (@: struct 'casting?))
					(cons 'in-combat? (@: struct 'in-combat?)) ; TODO fighting?
					(cons 'alike-dead? (@: struct 'alike-dead?))

					(cons 'angle (@: struct 'angle))
					(cons 'position (@: struct 'position))
					(cons 'destination (@: struct 'destination))
					(cons 'collision-radius (@: struct 'collision-radius))
					(cons 'collision-height (@: struct 'collision-height))

					(cons 'magical-attack-speed (@: struct 'magical-attack-speed))
					(cons 'physical-attack-speed (@: struct 'physical-attack-speed))
					(cons 'move-speed-factor (@: struct 'move-speed-factor))
					(cons 'attack-speed-factor (@: struct 'attack-speed-factor))

					(cons 'run-speed (@: struct 'run-speed))
					(cons 'walk-speed (@: struct 'walk-speed))
					(cons 'swim-run-speed (@: struct 'swim-run-speed))
					(cons 'swim-walk-speed (@: struct 'swim-walk-speed))
					(cons 'fly-run-speed (@: struct 'fly-run-speed))
					(cons 'fly-walk-speed (@: struct 'fly-walk-speed))

					(cons 'clothing (@: struct 'clothing))
				))
			)
		)
	)

	(define (update-creature creature struct)
		(let ((creature (update-object creature struct)))
			(struct-transfer creature struct
				'name
				'title
				'target-id
				'hp
				'mp
				'max-hp
				'max-mp
				'sitting?
				'running?
				'casting? ; TODO skill-id, last-skill-id
				'in-combat?
				'alike-dead?
				'angle
				'position
				'destination
				'collision-radius
				'collision-height
				'magical-attack-speed
				'physical-attack-speed
				'move-speed-factor
				'attack-speed-factor
				'run-speed
				'walk-speed
				'swim-run-speed
				'swim-walk-speed
				'fly-run-speed
				'fly-walk-speed
				'clothing
			)
		)
	)

	(define (update-creature! creature struct)
		(set-box! creature (update-creature (unbox creature) struct))
	)

	(define (casting? creature)
		; TODO (if casting-skill-id #t #f)
		(@: creature 'casting?)
	)

	(define (moving? creature)
		(let ((destination (@: creature 'destination)))
			(and
				destination
				(not (equal? (@: creature 'position) destination))
				(not (casting? creature))
				; TODO not immobilized effect
			)
		)
	)

	; (define (alive? creature)
	; 	(not (@: creature 'alike-dead?))
	; )

	(define (get-angle creature)
		; TODO if creature? and moving? then f(position, destination)
		; TODO else if creature? and casting? then f(position, target.position)
		; TODO else angle
		; TODO convert to math angle automaticaly?
		(@: creature 'angle)
	)

	(define (get-position creature)
		; TODO calculate based on last-position, last-move and speed
		(@: creature 'position)
	)

	(define (creatures-angle a b)
		(points-angle (get-position a) (get-position b))
	)

	(define (creatures-distance a b)
		(points-distance (get-position a) (get-position b))
	)
)
