(module logic racket/base
	(require
		(only-in srfi/1 proper-list?)
		(only-in racket/function negate)
		racket/contract
		"../library/date_time.scm"
		"../library/extension.scm"
		"../system/structure.scm"
	)
	(provide (contract-out
		(skill? (-> any/c boolean?))
		(skill-id (-> skill? integer?))
		(skill-ready? (-> skill? boolean?))
		(make-skill (->* (integer? integer?) (boolean? rational? rational?) box?))
		(update-skill! (-> box? list? list?))
		(set-skill-used! (->* (skill?) (rational? rational?) any))

		(select-skills (->* () #:rest list? list?))
		(skill-harmful? (-> integer? boolean?))
	))

	(define (skill? skill)
		(if (and skill (box? skill) (proper-list? (unbox skill)) (ref skill 'skill-id)) #t #f)
	)

	(define (skill-id skill)
		(ref skill 'skill-id)
	)

	(define (skill-ready? skill)
		(let ((last-usage (ref skill 'last-usage)) (reuse-delay (ref skill 'reuse-delay)))
			(and (ref skill 'active?) (> (timestamp) (+ last-usage reuse-delay)))
		)
	)

	(define (make-skill skill-id level [active? #t] [last-usage 0] [reuse-delay 0])
		(box (list
			(cons 'skill-id skill-id)
			(cons 'level level)
			(cons 'active? active?)
			(cons 'last-usage last-usage)
			(cons 'reuse-delay reuse-delay)
		))
	)

	(define (update-skill skill data)
		(struct-update data (list
			(cons 'skill-id (negate =))
			(cons 'level (negate =))
			(cons 'active? (negate eq?))
			(cons 'last-usage (negate =))
			(cons 'reuse-delay (negate =))
		) skill)
	)
	(define (update-skill! skill data)
		(let-values (((rest updated changes) (update-skill (unbox skill) data)))
			(set-box! skill (append rest updated))
			changes
		)
	)

	(define (set-skill-used! skill [last-usage (timestamp)] [reuse-delay #f])
		(update-skill! skill (list
			(cons 'last-usage last-usage)
			(and reuse-delay (cons 'reuse-delay reuse-delay))
		))
		(void)
	)

	; TODO Use shared database.
	(define skills (list
		; Heals.
		(cons 1011 'heal)
		(cons 1015 'battle-heal)
		(cons 1027 'group-heal)
		(cons 1217 'greater-heal)
		(cons 1218 'greater-battle-heal)
		(cons 1219 'greater-group-help)
		(cons 58 'elemental-heal)
		(cons 262 'holy-blessing)

		; Regens.
		(cons 1013 'recharge)

		; Cures.
		(cons 1012 'cure-poision)
		(cons 1018 'purify)
		(cons 1020 'vitalize)
		(cons 34 'bandage)
		(cons 61 'cure-bleeding)

		; Buffs & encouragements.
		(cons 1035 'mental-shield)
		(cons 1040 'shield)
		(cons 1059 'empower)
		(cons 1068 'might)
		(cons 1073 'kiss-of-eva)
		(cons 1077 'focus)
		(cons 1078 'concentration)
		(cons 1085 'acumen)
		(cons 1204 'wind-walk)
		(cons 1240 'guidance)
		(cons 1242 'death-whisper)
		(cons 1268 'vampiric-rage)

		(cons 77 'attack-aura)
		(cons 91 'defense-aura)
		(cons 78 'war-cry)
		(cons 82 'majesty)
		(cons 110 'ultimate-defense)

		; Toggles.
		(cons 256 'accuracy)
		(cons 312 'vicious-stance)

		; Strikes.
		(cons 3 'power-strike)
		(cons 16 'mortal-blow)
		(cons 56 'power-shot)
		(cons 100 'stun-attack)
		(cons 260 'hammer-crush)
		(cons 92 'shield-stun)
		(cons 245 'wild-sweep)
		(cons 36 'whirlwind)
		(cons 1239 'hurricane)
		(cons 1267 'shadow-flare)
		(cons 1234 'vampiric-claw)

		(cons 70 'drain-health)

		; Poisoning and bleeding.
		(cons 129 'poison)
		(cons 223 'sting)
		(cons 1168 'curse-poison)

		; Other harmful
		(cons 28 'hate)
		(cons 254 'spoil)
		(cons 302 'spoil-festival)

		; Other neutral.
		(cons 60 'fake-death)
		(cons 1016 'resurrection)
		(cons 1254 'mass-resurrection)
		(cons 1255 'party-recall)
		(cons 226 'relax)
		(cons 42 'sweeper)
		(cons 444 'sweeper-festival)
	))
	(define (select-skills . names)
		(let ((db (alist-flip skills)))
			(map (lambda (name)
				(let ((p (assoc name db eq?)))
					(if p
						(cdr p)
						(raise-user-error "Skill missed in the database." name)
					)
				)
			) names)
		)
	)
	(define (positive-skills)
		(select-skills
			'heal 'battle-heal 'group-heal 'greater-heal 'greater-battle-heal 'greater-group-help 'elemental-heal 'holy-blessing
			'recharge
			'cure-poision 'purify 'vitalize
			'mental-shield 'shield 'empower 'might 'kiss-of-eva 'focus 'concentration 'acumen 'wind-walk 'guidance 'death-whisper 'vampiric-rage
			'resurrection 'mass-resurrection 'party-recall
		)
	)
	(define (skill-harmful? skill-id)
		(not (member skill-id (positive-skills) =))
	)
)
