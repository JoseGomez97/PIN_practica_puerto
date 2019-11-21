(define (problem tower6)
   (:domain puerto)

    (:objects
        band1 band2 - band
        dock1 dock2 - dock
        crane1 crane2 - crane
        c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 - container
        s1 s2 s3 - stack
        l1 l2 l3 - level
    )

    (:init
        ; Cintas
        (direction band1 dock1 dock2)
        (direction band2 dock2 dock1)
        ; Posición gruas
        (at crane1 dock1)
        (at crane2 dock2)
        ; Niveles
        (next l1 l2)
        (next l2 l3)
        ;Tema Stacks
        (at s1 dock1)
        (at s2 dock1)
        (at s3 dock1)
        (at s1 dock2)
        (at s2 dock2)
        (at s3 dock2)
        ; Tema pilas
        (at c1 dock1)
        (at c2 dock2)
        (at c3 dock2)
        (at c4 dock2)
        (at c5 dock2)
        (at c6 dock2)
        (at c7 dock1)
        (at c8 dock2)
        (at c9 dock1)
        (at c10 dock1)
        (at c11 dock1)
        (on-level-stack c1 l1 s1)
        (on-level-stack c7 l2 s1)
        (on-level-stack c9 l1 s2)
        (on-level-stack c10 l2 s2)
        (on-level-stack c11 l1 s3)
        (on-level-stack c4 l1 s1)
        (on-level-stack c8 l2 s1)
        (on-level-stack c5 l1 s2)
        (on-level-stack c3 l2 s2)
        (on-level-stack c2 l2 s1)
        (on-level-stack c6 l1 s3)
        ; Contenedores Objetivos
        (is-objective c3)
        (is-objective c4)
        (is-objective c7)
        (free c7)
    )

    (:goal 
        (and 
            (at c3 dock1)
            (at c4 dock1)
            (at c7 dock1)
            (free c3)
            (free c4)
            (free c7)
            
        )
    )
    ;un-comment the following line if metric is needed
    ;(:metric minimize (???))
)
