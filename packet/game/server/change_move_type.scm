(module system racket/base
	(require "../../packet.scm")
	(provide game-server-packet/change-move-type)

	(define (game-server-packet/change-move-type buffer)
		(let ((s (open-input-bytes buffer)))
			(list
				(cons 'id (read-byte s))
				(cons 'object-id (read-int32 #f s))
				(cons 'walking? (zero? (read-int32 #f s)))
			)
		)
	)
)
