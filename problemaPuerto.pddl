(define (problem tower6)
   (:domain puerto)

    (:objects
        band1 band2 - band
        dock1 dock2 - dock
        crane1 crane2 - crane
        c1 c2 c3 c4 c5 c6 - container
        s1 s2 s3 - stack
        l1 l2 l3 - level
    )

    (:init
        ;
        ; Posición gruas
        (at crane1 dock1)
        (at crane2 dock2)
        ; Tema Niveles
        (next l0 l1)
        (next l1 l2)
        (next l2 l3)
    )

    (:goal 
        (and 
            (on a b) (on b c) (on c d) (on d e) (on e f)
        )
    )
    ;un-comment the following line if metric is needed
    ;(:metric minimize (???))
)
