;Header and description

(define (domain puerto)

;remove requirements that are not needed
(:requirements :typing :fluents :durative-actions)

(:types ;enumerate types and their hierarchy here
    container dock crane band stack level
)

; un-comment following line if constants are needed
;(:constants )

(:predicates ;define predicates here
            (on ?c1 - container ?c2 - (either crane band)) ;obtener contenedor en grua o cinta
            (free ?c - (either crane band container)) ;libre container, grua o cinta
            (on-lsd ?c - container ?l - level ?s - stack ?d - dock) ;obtener contenedor posición
            (free-lsd ?l - level ?s - stack ?d - dock) ;libre nivel de cierto stack en dock
            (at ?c1 - (either container crane) ?d - dock) ;dock del contenedor
            (next ?l1 - level ?l2 - level)
            (first ?l - level) ;nivel a ras de tierra, para los ground
            (is-objective ?c - container)
            ; Dirección de la cinta b
            (direction ?b - band ?origen - dock ?destino - dock)
)

(:functions 
    (weight ?c - container)
    (time-transport ?d1 - dock ?d2 - dock)
    (time-per-height ?l - level)
    (time-put-take-band ?b - band)
    (crane-fuel ?c - crane)
    (slow-burn ?c - crane)
    (total-fuel-used)
    (inverter)
    (refuel-time)
)

;; ACTIONS

(:durative-action take-from-stack
    :parameters (?crane - crane ?container - container ?prevContainer - container ?stack - stack ?l1 - level ?l2 - level ?dock - dock)
    :duration (= ?duration (* (weight ?container) (time-per-height ?l1)))
    :condition (and 
        (at start (free ?crane))
        (at start (free ?container))
        (at start (on-lsd ?container ?l1 ?stack ?dock))
        (over all (at ?crane ?dock))
        (over all (next ?l2 ?l1))
        (over all (on-lsd ?prevContainer ?l2 ?stack ?dock))
        (at start (>= (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?l1)))
        ))
    )
    :effect (and 
        (at start (not (free ?crane)))
        (at start (not (free ?container)))
        (at start (not (on-lsd ?container ?l1 ?stack ?dock)))
        (at end (free ?prevContainer))
        (at end (free-lsd ?l1 ?stack ?dock))
        (at end (on ?container ?crane))
        (at end (decrease (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?l1)))
        ))
        (at end (increase (total-fuel-used)
            (/ (inverter) (* (weight ?container) (time-per-height ?l1)))
        ))
    )
)


(:durative-action take-from-ground
    :parameters (?crane - crane ?container - container ?stack - stack ?l1 - level ?l2 - level ?dock - dock)
    :duration (= ?duration (* (weight ?container) (time-per-height ?l1)))
    :condition (and 
        (at start (free ?crane))
        (at start (on-lsd ?container ?l1 ?stack ?dock))
        (over all (at ?crane ?dock))
        (over all (first ?l1))
        (over all (next ?l1 ?l2))
        (over all (free-lsd ?l2 ?stack ?dock))
        (at start (>= (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?l1)))
        ))
    )
    :effect (and 
        (at start (not (free ?crane)))
        (at start (not (free ?container)))
        (at start (not (on-lsd ?container ?l1 ?stack ?dock)))
        (at end (free-lsd ?l1 ?stack ?dock))
        (at end (on ?container ?crane))
        (at end (decrease (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?l1)))
        ))
        (at end (increase (total-fuel-used)
            (/ (inverter) (* (weight ?container) (time-per-height ?l1)))
        ))
    )
)


(:durative-action put-on-container
    :parameters (?crane - crane ?stack - stack ?l1 - level ?l2 - level ?c1 - container ?c2 - container ?dock - dock)
    :duration (= ?duration (* (weight ?c1) (time-per-height ?l1)))
    :condition (and 
        (at start (on ?c1 ?crane))
        (at start (free ?c2))
        (at start (free-lsd ?l1 ?stack ?dock))
        (over all (at ?crane ?dock))
        (over all (next ?l2 ?l1))
        (over all (on-lsd ?c2 ?l2 ?stack ?dock))
        (at start (>= (crane-fuel ?crane)
            (/ 1 (* (weight ?c1) (time-per-height ?l1)))
        ))
    )
    :effect (and 
        (at start (not (on ?c1 ?crane)))
        (at start (not(free ?c2)))
        (at start (not(free-lsd ?l1 ?stack ?dock)))
        (at end (on-lsd ?c1 ?l1 ?stack ?dock))
        (at end (free ?crane))
        (at end (free ?c1))
        (at end (decrease (crane-fuel ?crane)
            (/ (inverter) (* (weight ?c1) (time-per-height ?l1)))
        ))
        (at end (increase (total-fuel-used)
            (/ (inverter) (* (weight ?c1) (time-per-height ?l1)))
        ))
    )
)

(:durative-action put-green-on-green
    :parameters (?crane - crane ?stack - stack ?level - level ?prevLevel - level ?prevContainer - container ?container - container ?dock - dock)
    :duration (= ?duration (* (weight ?container) (time-per-height ?level)))
    :condition (and 
        (at start (on ?container ?crane))
        (at start (free ?prevContainer))
        (at start (free-lsd ?level ?stack ?dock))
        (at start (>= (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?level)))
        ))
        (over all (at ?crane ?dock))
        (over all (on-lsd ?prevContainer ?prevLevel ?stack ?dock))
        (over all (next ?prevLevel ?level))
        (over all (is-objective ?container))
        (over all (is-objective ?prevContainer))
    )
    :effect (and 
        (at start (not (on ?container ?crane)))
        (at start (not(free-lsd ?level ?stack ?dock)))
        (at end (free ?crane))
        (at end (on-lsd ?container ?level ?stack ?dock))
        (at end (free ?container))
        (at end (decrease (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?level)))
        ))
        (at end (increase (total-fuel-used)
            (/ (inverter) (* (weight ?container) (time-per-height ?level)))
        ))
    )
)

(:durative-action put-on-ground
    :parameters (?crane - crane ?stack - stack ?level - level ?container - container ?dock - dock)
    :duration (= ?duration (* (weight ?container) (time-per-height ?level)))
    :condition (and
        (at start (on ?container ?crane))
        (at start (free-lsd ?level ?stack ?dock))
        (at start (>= (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?level)))
        ))
        (over all (at ?crane ?dock))
        (over all (first ?level))
    )
    :effect (and 
        (at start (not (on ?container ?crane)))
        (at start (not(free-lsd ?level ?stack ?dock)))
        (at end(free ?crane))
        (at end (on-lsd ?container ?level ?stack ?dock))
        (at end (free ?container))
        (at end (decrease (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-per-height ?level)))
        ))
        (at end (increase (total-fuel-used)
            (/ (inverter) (* (weight ?container) (time-per-height ?level)))
        ))
    )
)

(:durative-action put-on-band
    :parameters (?crane - crane ?container - container ?band - band ?dock - dock ?dock2 - dock)
    :duration (= ?duration (* (weight ?container) (time-put-take-band ?band)))
    :condition (and 
        (at start (on ?container ?crane))
        (at start (free ?band))
        (at start (>= (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-put-take-band ?band)))
        ))
        (over all (at ?crane ?dock))
        (over all (direction ?band ?dock ?dock2))
    )
    :effect (and 
        (at start (not(on ?container ?crane)))
        (at start (not (free ?band)))
        (at end (on ?container ?band))
        (at end (free ?crane))
        ;Transporte en la cinta *Anulado en este Dominio para aprovechar el paralelismo de los planificadores*
        ;(not (at ?container ?dock))
        ;at ?container ?dock2)
        (at end (decrease (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-put-take-band ?band)))
        ))
        (at end (increase (total-fuel-used)
            (/ (inverter) (* (weight ?container) (time-put-take-band ?band)))
        ))
    )
)

(:durative-action take-from-band
    :parameters (?band - band ?crane - crane ?container - container ?stack - stack ?level - level ?dock - dock ?dock2 - dock)
    :duration (= ?duration (* (weight ?container) (time-put-take-band ?band)))
    :condition (and 
        ;La grua no esta ocupada
        (at start (free ?crane))
        ;Hay un container en la banda
        (at start (on ?container ?band))
        (at start (>= (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-put-take-band ?band)))
        ))
        (over all (direction ?band ?dock2 ?dock))
        ;El container y la grua se encuentran en el mismo dock
        (over all (at ?container ?dock))
        (over all (at ?crane ?dock))
    )
    :effect (and 
        (at start (not (free ?crane)))
        (at end (free ?band))
        (at start (not(on ?container ?band)))
        (at end (on ?container ?crane))
        (at end (decrease (crane-fuel ?crane)
            (/ (inverter) (* (weight ?container) (time-put-take-band ?band)))
        ))
        (at end (increase (total-fuel-used)
            (/ (inverter) (* (weight ?container) (time-put-take-band ?band)))
        ))
    )
)

;;NUEVA REGLA para el DOMINIO TEMPORAL
(:durative-action transport
    :parameters (?band - band ?container - container ?dock - dock ?dock2 - dock)
    :duration (= ?duration (time-transport ?dock ?dock2))
    :condition (and 
        (at start (at ?container ?dock))
        (over all (on ?container ?band))
        (over all (direction ?band ?dock ?dock2))
    )
    :effect (and 
        (at start (not (at ?container ?dock)))
        (at end (at ?container ?dock2))
    )
)


;;NUEVA REGLA para el DOMINIO NUMERICO
(:durative-action refuel
    :parameters (?crane - crane)
    :duration (= ?duration (refuel-time))
    :condition (and 
        (at start (free ?crane))
    )
    :effect (and 
        (at end (assign (crane-fuel ?crane) 50))
    )
)

)