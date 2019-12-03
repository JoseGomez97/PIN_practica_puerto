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
            (free ?c - (either crane band container)) ;ocupado container, grua o cinta
            (on-lsd ?c - container ?l - level ?s - stack ?d - dock) ;obtener contenedor posición
            (free-lsd ?l - level ?s - stack ?d - dock) ;ocupado nivel de cierto stack en dock
            (at ?c1 - (either container crane) ?d - dock) ;dock del contenedor
            (next ?l1 - level ?l2 - level)
            (first ?l - level) ;nivel a ras de tierra, para los ground
            (top ?l - level) ;indica si está arriba del todo
            (is-objective ?c - container)
            ; Dirección de la cinta b
            (direction ?b - band ?origen - dock ?destino - dock)
)

;; ACTIONS
(:action take-from-top-stack
    :parameters (?crane - crane ?dock - dock ?container - container ?prevContainer - container ?stack - stack ?l0 - level ?l1 - level)
    :precondition (and 
        ;la grua no esta ocupada
        (free ?crane)
        ;obtenemos dock de la grua
        (at ?crane ?dock)
        ;obtener niveles por orden
        (next ?l0 ?l1)
        (top ?l1);aun no ze zabe si con (free ?container) podria cubrir tmb el siguiente método
        ;asegurar que hay un container en dicho nivel, stack y dock
        (on-lsd ?container ?l1 ?stack ?dock)
        ;obtenemos el container de abajo
        (on-lsd ?prevContainer ?l0 ?stack ?dock)
    )
    :effect (and 
        ;se desocupa donde estuviese el container
        (free-lsd ?l1 ?stack ?dock)
        (not (on-lsd ?container ?l1 ?stack ?dock))
        ;se ocupa la grua correspondiente
        (not (free ?crane))
        (on ?container ?crane)
        
        (free ?prevContainer)
        (not (free ?container))
        (not (free ?crane))
    )
)
;DONEte (supuestamente): dudoso de si tiene utilidad, si es por diferenciar cuando es top de las otras veces que es free solo, simplemente se puede quitar 
;de la anterior el (top ?l1) y poner (free ?container) y funcionaria para los dos casos
(:action take-from-mid-stack
    :parameters (?crane - crane ?container - container ?prevContainer -container ?stack - stack ?l0 - level ?l1 - level ?dock - dock)
    :precondition (and 
        ;la grua no esta ocupada
        (free ?crane)
        (at ?crane ?dock)
        ;obtener niveles por orden
        (next ?l0 ?l1)
        ;el container no tiene ningún container arriba
        (free ?container)
        ;asegurar que hay un container en dicho nivel y stack
        (on-lsd ?container ?l1 ?stack ?dock)
        ;obtenemos el container de abajo
        (on-lsd ?prevContainer ?l0 ?stack ?dock)
    )
    :effect (and 
        ;se desocupa donde estuviese el container
        (free-lsd ?l1 ?stack ?dock)
        (not (on-lsd ?container ?l1 ?stack ?dock))
        ;se ocupa la grua correspondiente
        (on ?container ?crane)
        
        (free ?prevContainer)
        (not (free ?container))
        (not (free ?crane))
    )
)
;DONEte (supuestamente)
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
        (on ?container ?crane)
        
        (not (free ?container))
        (not (free ?crane))
    )
)

;OJO: se me ha ocurrido que todos los TAKE's se podrían hacer todas en una misma rutina, teniendo en cuenta el quitar los free's y top's,
;y dejarselo luego a una rutina que comprobase por cada container si el siguiente nivel es free-lsd, y lo ponga a este container en free
;es algo que antes no podiamos porque no teniamos ese predicado

;DONEte (supuestamente)
(:action take-from-band
    :parameters (?band - band ?crane - crane ?container - container ?stack - stack ?level - level ?dock - dock)
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

;DONEte (supuestamente)
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
    )
)

;OJO: apartir de ahora, una buena practica a tener en mente es que en los EFFECT's, cada (not(on/on-lsd)), le tiene que acompañar un (free/free-lsd)
;al igual que cada (not(free/free-lsd)), le tiene que acompañar un (on/on-lsd) *esto último no se cumple SOLO cuando se mete un contenedor directamente en el suelo

;DONEte (supuestamente)
(:action put-on-top-stack
    :parameters (?crane - crane ?stack - stack ?l0 - level ?l1 - level ?l2 - level ?prevCont0 - container ?prevCont1 - container ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        ;grua y stack en el puerto correcto
        (at ?crane ?dock)
        ;el nivel correspondiente no está ocupado y es top
        (free-lsd ?l2 ?stack ?dock)
        (top ?l2)
        ;se averigua los nivele anteriores
        (next ?l1 ?l2)
        (next ?l0 ?l1)
        ;obtenemos los otros containers
        (on-lsd ?prevCont0 ?l1 ?stack ?dock)
        (on-lsd ?prevCont1 ?l0 ?stack ?dock)
    )
    :effect (and 
        (not (on ?container ?crane))
        (free ?crane)

        (on-lsd ?container ?l2 ?stack ?dock)
        (not(free-lsd ?l2 ?stack ?dock))
        ;estos dos siguientes no los toco, pero no se porque los has puesto :(
        ;desduzco que por lo del problema de que cuando ponias los objetivos a free's y todo eso, se quedaban a veces free's de mas
        (not (free ?prevCont0))
        (not (free ?prevCont1))
        (free ?container)
    )
)
;DONEte (supuestamente)
(:action put-on-mid-stack
    :parameters (?crane - crane ?stack - stack ?level - level ?prevLevel - level ?prevContainer - container ?container - container ?dock - dock)
    :precondition (and 
        ;container en grua
        (on ?container ?crane)
        ;grua y stack en el puerto correcto
        (at ?crane ?dock)
        ;obtenemos los niveles, el libre que va a ser ocupado, y el anterior que tendra el free del container
        (free-lsd ?level ?stack ?dock)
        (next ?prevLevel ?level)
        ;el nivel anterior está ocupado y sacamos su container para ponerle luego el free
        (on-lsd ?prevContainer ?prevLevel ?stack ?dock)
    )
    :effect (and 
        (not (on ?container ?crane))
        (free ?crane)

        (not(free-lsd ?level ?stack ?dock))
        (on-lsd ?container ?level ?stack ?dock)

        (not (free ?prevContainer))
        (free ?container)
    )
)
;DONEte (supuestamente)
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
;DONEte(supuestamente)
(:action trasport
    :parameters (?band - band ?d1 - dock ?d2 - dock ?container - container)
    :precondition (and
        (direction ?band ?d1 ?d2)
        (on ?container ?band)
    )
    :effect (and 
        (not (at ?container ?d1))
        (at ?container ?d2)
    )
)
;TODO
(:action down-is-free-too
    ;metodo para saber si un bloque de abajo 
    :parameters (?container - container ?c2 - container ?stack - stack ?l1 - level ?l2 - level ?dock - dock)
    :precondition (and
        (is-objective ?container)
        (free ?container)
        (on-lsd ?container ?l1 ?stack ?dock)
        (next ?l2 ?l1)
        (on-lsd ?c2 ?l2 ?stack ?dock)
        (is-objective ?c2)
    )
    :effect (and 
        (free ?c2)
    )
)




;OJO a lo que se viene

(:action take-general
    :parameters (?crane - crane ?container - container ?stack - stack ?l1 - level ?l2 - level ?dock - dock)
    :precondition (and 
        ;La grua no esta ocupada
        (free ?crane)
        (at ?crane ?dock)
        (on-lsd ?container ?l1 ?stack ?dock)
        ;Obtenemos el siguiente nivel
        (next ?l1 ?l2)
        (free-lsd ?l2 ?stack ?dock)
    )
    :effect (and 
        ; Se desocupa donde estuviese el container
        (free-lsd ?l1 ?stack ?dock)
        (not (on-lsd ?container ?l1 ?stack ?dock))
        ;Se ocupa la grua correspondiente
        (on ?container ?crane)

        (not (free ?crane))
    )
)




)