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
        (next l2 l3)
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
        (free-lsd l3 s1 dock1)
        (free c7)
        ; s2
        (on-lsd c9 l1 s2 dock1)
        (on-lsd c10 l2 s2 dock1)
        (free-lsd l3 s2 dock1)
        (free c10)
        ; s3
        (on-lsd c11 l1 s3 dock1)
        (free-lsd l2 s3 dock1)
        (free-lsd l3 s3 dock1)
        (free c11)
        ;Stacks dock2
        ; s1
        (on-lsd c4 l1 s1 dock2)
        (on-lsd c8 l2 s1 dock2)
        (free-lsd l3 s1 dock2)
        (free c8)
        ; s2
        (on-lsd c5 l1 s2 dock2)
        (on-lsd c3 l2 s2 dock2)
        (on-lsd c2 l3 s2 dock2)
        (free c2)
        ;s3
        (on-lsd c6 l1 s3 dock2)
        (free-lsd l2 s3 dock2)
        (free-lsd l3 s3 dock2)
        (free c6)
        ; Contenedores Objetivos
        (is-objective c3)
        (is-objective c4)
        (is-objective c7)
        ;;DOMINIO TEMPORAL
        (= (total-time-used) 0)
        (= (time-transport dock1 dock2) 10)
        (= (time-transport dock2 dock1) 10)
        (= (time-per-height l1) 0.3)
        (= (time-per-height l2) 0.2)
        (= (time-per-height l3) 0.1)
        (= (weight c1) 50)
        (= (weight c2) 50)
        (= (weight c3) 50)
        (= (weight c4) 50)
        (= (weight c5) 50)
        (= (weight c6) 50)
        (= (weight c7) 50)
        (= (weight c8) 50)
        (= (weight c9) 50)
        (= (weight c10) 50)
        (= (weight c11) 50)
        (= (time-put-take-band band1) 0.3)
        (= (time-put-take-band band2) 0.3)

        (= (crane-fuel crane1) 50)
        (= (crane-fuel crane2) 50)
        (= (total-fuel-used) 0)
        (= (inverter) 10)
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
    (:metric
        minimize (total-time)
        minimize (total-fuel-used)
    )
)
