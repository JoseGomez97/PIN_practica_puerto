(define (problem tower6)
   (:domain puerto)

    (:objects
        band1 band2 - band
        dock1 dock2 - dock
        crane1 crane2 - crane
        c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 - container
        s1 s2 s3 - stack
        l1 l2 - level
    )

    (:init
        ; Cintas
        (direction band1 dock1 dock2)
        (free band1)
        (direction band2 dock2 dock1)
        (free band2)
        ; Posición gruas
        (at crane1 dock1)
        (at crane2 dock2)
        (free crane1)
        (free crane2)
        ; Niveles
        (first l1)
        (next l1 l2)
        ; Tema containers
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
        ;Stacks dock1
        ; s1
        (on-lsd c1 l1 s1 dock1)
        (on-lsd c7 l2 s1 dock1)
        (free c7)
        ; s2
        (on-lsd c9 l1 s2 dock1)
        (on-lsd c10 l2 s2 dock1)
        (free c10)
        ; s3
        (on-lsd c11 l1 s3 dock1)
        (free-lsd l2 s3 dock1)
        (free c11)
        ;Stacks dock2
        ; s1
        (on-lsd c4 l1 s1 dock2)
        (on-lsd c8 l2 s1 dock2)
        (free c8)
        ; s2
        (on-lsd c5 l1 s2 dock2)
        (on-lsd c3 l2 s2 dock2)
        (free c3)
        ;s3
        (on-lsd c6 l1 s3 dock2)
        (on-lsd c2 l2 s3 dock2)
        (free c2)
        ; Contenedores Objetivos
        (is-objective c3)
        (is-objective c4)
        (is-objective c7)
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
