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
    )
    :effect (and 
        (at start (not (free ?crane)))
        (at start (not (free ?container)))
        (at start (not (on-lsd ?container ?l1 ?stack ?dock)))
        (at end (free ?prevContainer))
        (at end (free-lsd ?l1 ?stack ?dock))
        (at end (on ?container ?crane))          
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
    )
    :effect (and 
        (at start (not (free ?crane)))
        (at start (not (free ?container)))
        (at start (not (on-lsd ?container ?l1 ?stack ?dock)))
        (at end (free-lsd ?l1 ?stack ?dock))
        (at end (on ?container ?crane))
        
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
    )
    :effect (and 
        (at start (not (on ?c1 ?crane)))
        (at start (not(free ?c2)))
        (at start (not(free-lsd ?l1 ?stack ?dock)))
        (at end (on-lsd ?c1 ?l1 ?stack ?dock))
        (at end (free ?crane))
        (at end (free ?c1))
    )
)

(:durative-action put-green-on-green
    :parameters (?crane - crane ?stack - stack ?level - level ?prevLevel - level ?prevContainer - container ?container - container ?dock - dock)
    :duration (= ?duration (* (weight ?container) (time-per-height ?level)))
    :condition (and 
        (at start (on ?container ?crane))
        (at start (free ?prevContainer))
        (at start (free-lsd ?level ?stack ?dock))
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
    )
)

;TODO
(:action put-on-ground
    :parameters (?crane - crane ?stack - stack ?level - level ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        ;grua y stack en el puerto correcto
        (at ?crane ?dock)
        ;el nivel correspondiente no está ocupado
        (first ?level)
        (free-lsd ?level ?stack ?dock)
    )
    :effect (and 

        (not (on ?container ?crane))
        (free ?crane)

        (on-lsd ?container ?level ?stack ?dock)
        (not(free-lsd ?level ?stack ?dock))
        ;free
        (free ?container)
        ;Dominio Temporal
        (increase (total-time-used)
            (* (weight ?container) (time-per-height ?level)))
    )
)
;TODO
(:action put-on-band
    :parameters (?crane - crane ?container - container ?band - band ?dock - dock ?dock2 - dock)
    :precondition (and 
        ;La grua tiene que tener el container
        (on ?container ?crane)
        ;La grua y el origen de la cinta tienen que estar en el mismo dock
        (at ?crane ?dock)
        (direction ?band ?dock ?dock2)
        ;La cinta no tiene que tener nada
        (free ?band) 
    )
    :effect (and 
        ;Se deja libre la grua del container
        (not(on ?container ?crane))
        (free ?crane)
        ;Se coloca el container en la cinta
        (not (free ?band))
        (on ?container ?band)
        ;Transporte en la cinta *Anulado en este Dominio para aprovechar el paralelismo de *
        ;(not (at ?container ?dock))
        ;at ?container ?dock2)
        ;Dominio Temporal
        (increase (total-time-used)
            (* (weight ?container) (time-put-take-band ?band)))
    )
)
;TODO
(:action take-from-band
    :parameters (?band - band ?crane - crane ?container - container ?stack - stack ?level - level ?dock - dock ?dock2 - dock)
    :precondition (and 
        ;La grua no esta ocupada
        (free ?crane)
        ;Hay un container en la banda
        (on ?container ?band)
        (direction ?band ?dock2 ?dock)
        ;El container y la grua se encuentran en el mismo dock
        (at ?container ?dock)
        (at ?crane ?dock)
    )
    :effect (and 
        (not (free ?crane))
        (free ?band)
        (not(on ?container ?band))
        (on ?container ?crane)
        ;Dominio Temporal
        (increase (total-time-used)
            (* (weight ?container) (time-put-take-band ?band)))
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

)