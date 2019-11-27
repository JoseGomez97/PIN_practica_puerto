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
            (free ?c - container)
            ; Dirección de la cinta b
            (direction ?b - band ?origen - dock ?destino - dock)
)

;; ACTIONS
(:action take-from-top-stack
    :parameters (?crane - crane ?container - container ?prevContainer - container ?stack - stack ?l0 - level ?l1 - level)
    :precondition (and 
        ;la grua no esta ocupada
        (not (on ? ?crane))
        ;obtener niveles por orden
        (next ?l0 ?l1)
        (not (next ?l1 ?))
        ;asegurar que hay un container en dicho nivel y stack
        (on-level-stack ?container ?l1 ?stack)
        ;obtenemos el container de abajo
        (on-level-stack ?prevContainer ?l0 ?stack)
        ;compruebo que el dock sea el mismo para la grua, el container y el stack
        (at ?container ?dock)
        (at ?crane ?dock)
        (at ?stack ?dock)
    )
    :effect (and 
        ;se desocupa donde estuviese el container
        (not (on-level-stack ?container ?l1 ?stack))
        ;se ocupa la grua correspondiente
        (on ?container ?crane)
        
        (free ?prevContainer)
        (not (free ?container))
    )
)

(:action take-from-mid-stack
    :parameters (?crane - crane ?container - container ?prevContainer -container ?stack - stack ?l0 - level ?l1 - level ?l2 - level)
    :precondition (and 
        ;la grua no esta ocupada
        (not (on ? ?crane))
        ;obtener niveles por orden
        (next ?l0 ?l1)
        (next ?l1 ?l2)
        ;el container no tiene ningún container arriba
        (not (on-level-stack ? ?l2 ?stack))
        ;asegurar que hay un container en dicho nivel y stack
        (on-level-stack ?container ?l1 ?stack)
        ;obtenemos el container de abajo
        (on-level-stack ?prevContainer ?l0 ?stack)
        ;compruebo que el dock sea el mismo para la grua, el container y el stack
        (at ?container ?dock)
        (at ?crane ?dock)
        (at ?stack ?dock)
    )
    :effect (and 
        ;se desocupa donde estuviese el container
        (not (on-level-stack ?container ?l1 ?stack))
        ;se ocupa la grua correspondiente
        (on ?container ?crane)
        
        (free ?prevContainer)
        (not (free ?container))
    )
)

(:action take-from-ground
    :parameters (?crane - crane ?container - container ?stack - stack ?l1 - level ?l2 - level)
    :precondition (and 
        ;La grua no esta ocupada
        (not (on ? ?crane))
        ;No puede tener ningún nivel antes
        (not (next ? ?l1))
        ;Obtenemos el siguiente nivel
        (next ?l1 ?l2)
        ;Tiene que haber container en dicha posición
        (on-level-stack ?container ?l1 ?stack)
        ;No puede haber container en la siguiente posición
        (not (on-level-stack ? ?l2 ?stack))
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
        
        (not (free ?container))
    )
)

(:action take-from-band
    :parameters (?crane - crane ?container - container ?stack - stack ?level - level)
    :precondition (and 
        ;La grua no esta ocupada
        (not (on ? ?crane))
        ;Hay un container en la banda
        (on ?container ?band)
        ;El container y la grua se encuentran en el mismo dock
        (at ?container ?dock)
        (at ?crane ?dock)
    )
    :effect (and 
        (not (on ?container ?band))
        (on ?container ?crane)
    )
)


(:action put-on-band
    :parameters (?crane - crane ?container - container ?band - band ?dock - dock)
    :precondition (and 
        ;La grua tiene que tener el container
        (on ?container ?crane)
        ;La grua y el origen de la cinta tienen que estar en el mismo dock
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

(:action put-on-top-stack
    :parameters (?crane - crane ?stack - stack ?l0 - level ?l1 - level ?l2 - level ?prevCont0 - container ?prevCont1 - container ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        ;grua y stack en el puerto correcto
        (at ?crane ?dock)
        (at ?stack ?dock)
        ;obtenemos los niveles
        (next ?l0 ?l1)
        (next ?l1 ?l2)
        ;el nivel correspondiente no está ocupado
        (not (on-level-stack ? ?l2 ?stack))
        ;obtenemos los otros containers
        (on-level-stack ?prevCont1 ?l1 ?stack)
        (on-level-stack ?prevCont2 ?l2 ?stack)
    )
    :effect (and 
        (not (on ?container ?crane))
        (on-level-stack ?container ?level ?stack)

        (not (free ?prevCont0))
        (not (free ?prevCont1))
        (free ?container))
    )
)

(:action put-on-mid-stack
    :parameters (?crane - crane ?stack - stack ?level - level ?prevLevel - level ?prevContainer - container ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        ;grua y stack en el puerto correcto
        (at ?crane ?dock)
        (at ?stack ?dock)
        ;obtenemos los niveles
        (next ?prevLevel ?level)
        (next ?level ?)
        ;el nivel correspondiente no está ocupado
        (not (on-level-stack ? ?level ?stack))
        ;el nivel anterior está ocupado
        (on-level-stack ?prevContainer ?prevLevel ?stack)
    )
    :effect (and 
        (not (on ?container ?crane))
        (on-level-stack ?container ?level ?stack)

        (not (free ?prevContainer))
        (free ?container)
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
        ;free
        (free ?container)
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

(:action down-is-free-too
    ;metodo para saber si un bloque de abajo 
    :parameters (?container - container ?c2 - container ?stack - stack ?l1 - level ?l2 - level ?dock - dock)
    :precondition (and
        (is-objective ?container)
        (free ?container)
        (on-level-stack ?container ?l1 ?stack)
        (next ?l2 ?l1)
        (on-level-stack ?c2 ?l2 ?stack)
        (is-objective ?c2)
        (not (free ?c2))
        (at ?container ?dock)
        (at ?c2 ?dock)
        (at ?stack ?dock)
    )
    :effect (and 
        (free ?c2)
    )
)
