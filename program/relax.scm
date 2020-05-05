(module ai racket/base
	(require
		racket/undefined
		"program.scm"
		(relative-in "../."
			; "library/extension.scm"
			"system/structure.scm"
			"system/connection.scm"
			"system/event.scm"
			"model/object.scm"
			"model/protagonist.scm"
			"model/world.scm"
			"api/sit.scm"
		)
	)
	(provide program-relax)

	(define (program-error message . args) (apply raise-program-error 'program-relax message args))
	(define (error-already-restored hp mp) (program-error "Already restored." hp mp))
	(define (error-under-attack attackers) (apply program-error "I'm under attack!" attackers))
	(define (hp-max? creature) (= (ref creature 'hp) (ref creature 'max-hp)))
	(define (mp-max? creature) (= (ref creature 'mp) (ref creature 'max-mp)))

	(define-program program-relax
		(lambda (cn event config state)
			(let ((duration (car config)) (me (world-me (connection-world cn))))
				(if (case-event event ; End on fully restored or timeout.
					(creature-update (id changes)
						(and
							(= id (object-id me))
							(or (assq 'hp changes) (assq 'mp changes))
							(hp-max? me)
							(mp-max? me)
						)
					)
					(else (cond
						((eq? (event-name event) state) #t)
						((> (attackers-count me) 0)
							(error-under-attack (attackers me))
						)
						(else #f)
					))
				) eof state)
			)
		)

		#:constructor (lambda (cn config)
			(let* ((duration (car config)) (me (world-me (connection-world cn))))
				(when (> (attackers-count me) 0)
					(error-under-attack (attackers me))
				)

				(if (and (hp-max? me) (mp-max? me))
					(error-already-restored (ref me 'hp) (ref me 'mp))
					(begin
						(when (not (ref me 'sitting?))
							(sit cn #t)
						)
						(if (> duration 0)
							(timeout! cn duration)
							(void)
						)
					)
				)
			)
		)

		#:destructor (lambda (cn config state)
			(when (ref (world-me (connection-world cn)) 'sitting?)
				(sit cn #f)
			)
		)

		#:defaults (list
			0 ; duration
		)
	)
)