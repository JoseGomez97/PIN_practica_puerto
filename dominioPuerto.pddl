domain;Header and description

(define (domain puerto)

;remove requirements that are not needed
(:requirements :typing)

(:types ;enumerate types and their hierarchy here
    container dock crane band stack level
)

; un-comment following line if constants are needed
;(:constants )

(:predicates ;define predicates here
            (on ?c1 - container ?c2 - (either crane band))
            (on-level-stack ?c - container ?l - level ?s - stack)
            (at ?c1 - (either container crane stack) ?d - dock)
            (next ?l1 - level ?l2 - level)
            (is-objective ?c - container)
            ; Dirección de la cinta b
            (direction ?b - band ?origen - dock ?destino - dock)
)

;; ACTIONS
(:action take-from-stack
    :parameters (?crane - crane ?container - container ?stack - stack ?l1 - level ?l2 - level)
    :precondition (and 
        ;La grua no esta ocupada
        (not (on ? ?crane))
        ;Obtener niveles por orden
        (next ?l1 ?l2)
        ;El container no tiene ningún container arriba
        (not (on-level-stack ? ?l2 ?stack))
        ;Asegurar que hay un container en dicho nivel y stack
        (on-level-stack ?container ?l1 ?stack)
        ;Compruebo que el dock sea el mismo para la grua, el container y el stack
        (at ?container ?dock)
        (at ?crane ?dock)
        (at ?stack ?dock)
    )
    :effect (and 
        ; Se desocupa donde estuviese el container
        (not (on-level-stack ?container ?l1 ?stack))
        ;Se ocupa la grua correspondiente
        (on ?container ?crane)
    )
)

(:action take-from-ground
    :parameters (?crane - crane ?container - container ?stack - stack ?l1 - level ?l2 - level)
    :precondition (and 
        ;La grua no este ocupada
        (not (on ? ?crane))
        ;Instanciar un container libre
        (free ?container)
        ;Instanciar su nivel y stack
        (on-level-stack ?container ?l1 ?stack)
        ;Sacar el nivel anterior en la stack, y averiguar el container de abajo
        (next ?l2 ?l1)
        (not (on-level-stack ? ?l2 ?stack))
        ;Compruebo que el dock sea el mismo para la grua y el container
        (at ?container ?dock)
        (at ?crane ?dock)
    )
    :effect (and 
        ; Se desocupa donde estuviese el container
        (not (on-level-stack ?container ?l1 ?stack))
        ;Ya no esta libre porque esta en la grua
        (not (free ?container))
        ;Se ocupa la grua correspondiente
        (on ?container ?crane)
    )
)

(:action take-from-band
    :parameters (?crane - crane ?container - container ?c2 - container ?stack - stack ?l1 - level ?l2 - level)
    :precondition (and 
        ;La grua no este ocupada
        (not (on ? ?crane))
        (at ?crane ?dock)
        (direction ?band ? ?dock)
        (on ?container ?band)
    )
    :effect (and 
        (not (on ?container ?band))
        (on ?container ?crane)
    )
)


(:action put-on-band
    :parameters (?crane - crane ?container - container ?band - band ?dock - dock)
    :precondition (and 
        ;La grua tiene que tener el container y estar en el mismo dock que una cinta cuyo origen es ese dock
        (on ?container ?crane)
        (at ?crane ?dock)
        (direction ?band ?dock ?)
        ;La cinta no tiene que tener nada
        (not (on ? ?band))   
    )
    :effect (and 
        ;Se deja libre la grua del container
        (not(on ?container ?crane))
        ;Se coloca el container en la cinta
        (on ?container ?band)
    )
)

(:action put-on-stack
    :parameters (?crane - crane ?stack - stack ?level - level ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        ;grua y stack en el puerto correcto
        (at ?crane ?dock)
        (at ?stack ?dock)
        ;el nivel correspondiente no está ocupado
        (not (on-level-stack ? ?level ?stack))
        ;el nivel anterior está ocupado
        (on-level-stack ?prevContainer ?prevLevel ?stack)
        (next ?prevLevel ?level)
    )
    :effect (and 
        (not (on ?container ?crane))
        (on-level-stack ?container ?level ?stack)
        (not (free ?prevContainer))
    )
)

(:action put-on-ground
    :parameters (?crane - crane ?stack - stack ?level - level ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        ;grua y stack en el puerto correcto
        (at ?crane ?dock)
        (at ?stack ?dock)
        ;el nivel correspondiente no está ocupado
        (not (on-level-stack ? ?level ?stack))
        ;no hay nivel anterios
        (not (next ? ?level))
    )
    :effect (and 
        (not (on ?container ?crane))
        (on-level-stack ?container ?level ?stack)
    )
)

(:action trasport
    :parameters (?band - band ?d1 - dock ?d2 - dock ?container - container)
    :precondition (and
        (direction ?band ?d1 ?d2)
        (on ?container ?band)
    )
    :effect (and 
        (not (at ?container ?d1)
        (at ?container ?d2)
    )
)
