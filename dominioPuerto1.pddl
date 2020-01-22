;Header and description

(define (domain puerto)

;remove requirements that are not needed
(:requirements :typing)

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

;; ACTIONS

(:action take-from-stack
    :parameters (?crane - crane ?container - container ?prevContainer - container ?stack - stack ?l1 - level ?l2 - level ?dock - dock)
    :precondition (and 
        ;La grua no esta ocupada
        (free ?crane)
        (at ?crane ?dock)
        (free ?container)
        (on-lsd ?container ?l1 ?stack ?dock)
        ;Obtenemos el siguiente nivel
        (next ?l2 ?l1)
        (on-lsd ?prevContainer ?l2 ?stack ?dock)
    )
    :effect (and 
        ; Se desocupa donde estuviese el container
        (free-lsd ?l1 ?stack ?dock)
        (not (on-lsd ?container ?l1 ?stack ?dock))
        ;poner a free el anterior container
        (not(free ?container))
        (free ?prevContainer)
        ;Se ocupa la grua correspondiente
        (on ?container ?crane)
        (not (free ?crane))
    )
)


(:action take-from-ground
    :parameters (?crane - crane ?container - container ?stack - stack ?l1 - level ?l2 - level ?dock - dock)
    :precondition (and 
        ;La grua no esta ocupada
        (free ?crane)
        (at ?crane ?dock)
        ;No puede tener ningún nivel antes
        (first ?l1)
        ;Obtenemos el siguiente nivel
        (next ?l1 ?l2)
        ;Tiene que haber container en dicha posición
        (on-lsd ?container ?l1 ?stack ?dock)
        ;No puede haber container en la siguiente posición
        (free-lsd ?l2 ?stack ?dock)
    )
    :effect (and 
        ; Se desocupa donde estuviese el container
        (free-lsd ?l1 ?stack ?dock)
        (not (on-lsd ?container ?l1 ?stack ?dock))
        ;Se ocupa la grua correspondiente
        (not (free ?crane))
        (on ?container ?crane)
        
        (not (free ?container))
    )
)


(:action put-on-container
    :parameters (?crane - crane ?stack - stack ?l1 - level ?l2 - level ?c1 - container ?c2 - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?c1 ?crane)
        (at ?crane ?dock)
        ;obtenemos los niveles, el libre que va a ser ocupado, y el anterior que tendra el free del container
        (free ?c2)
        (next ?l2 ?l1)
        (on-lsd ?c2 ?l2 ?stack ?dock)
        (free-lsd ?l1 ?stack ?dock)
    )
    :effect (and 
        (not (on ?c1 ?crane))
        (free ?crane)

        (not(free-lsd ?l1 ?stack ?dock))
        (on-lsd ?c1 ?l1 ?stack ?dock)

        (not(free ?c2))
        (free ?c1)
    )
)

(:action put-green-on-green
    :parameters (?crane - crane ?stack - stack ?level - level ?prevLevel - level ?prevContainer - container ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        (at ?crane ?dock)
        ;obtenemos los niveles, el libre que va a ser ocupado, y el anterior que tendra el free del container
        (free ?prevContainer)
        (free-lsd ?level ?stack ?dock)
        (on-lsd ?prevContainer ?prevLevel ?stack ?dock)
        (next ?prevLevel ?level)
        (is-objective ?container)
        (is-objective ?prevContainer)
    )
    :effect (and 
        (not (on ?container ?crane))
        (free ?crane)

        (not(free-lsd ?level ?stack ?dock))
        (on-lsd ?container ?level ?stack ?dock)

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
    )
)


(:action take-from-band
    :parameters (?band - band ?crane - crane ?container - container ?dock - dock)
    :precondition (and 
        ;La grua no esta ocupada
        (free ?crane)
        ;Hay un container en la banda
        (on ?container ?band)
        ;El container y la grua se encuentran en el mismo dock
        (at ?container ?dock)
        (at ?crane ?dock)
    )
    :effect (and 
        (not (free ?crane))
        (free ?band)
        (not(on ?container ?band))
        (on ?container ?crane)
    )
)


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
        ;Transporte en la cinta
        (not (at ?container ?dock))
        (at ?container ?dock2)
    )
)

)