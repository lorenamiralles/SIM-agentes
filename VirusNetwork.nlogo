turtles-own
[
  infected?           ;; if true, the turtle is infectious
  resistant?          ;; if true, the turtle can't be infected
  virus-check-timer   ;; number of ticks since this turtle's last virus-check
]

to setup
  clear-all
  setup-nodes
  setup-spatially-clustered-network
  ask n-of initial-outbreak-size turtles
    [ become-infected ]
  ask links [ set color white ]
  reset-ticks
end

to setup-nodes
  set-default-shape turtles "circle"
  create-turtles number-of-nodes
  [
    ; for visual reasons, we don't put any nodes *too* close to the edges
    setxy (random-xcor * 0.95) (random-ycor * 0.95)
    become-susceptible
    set virus-check-timer random virus-check-frequency
  ]
end

to setup-spatially-clustered-network
  ; duplica la cantidad de enlaces puesto que ahora son dirigidos
  let num-links (average-node-degree * number-of-nodes)
  while [count links < num-links ]
  [
    ask one-of turtles
    [
      ; comprobamos que no exista enlace desde el otro nodo hasta el nodo propio
      let choice (min-one-of (other turtles with [not in-link-neighbor? myself])
                   [distance myself])
      ; si existe un nodo, creamos el enlace desde el nodo propio hasta el otro
      if choice != nobody [ create-link-to choice ]
    ]
  ]
  ; make the network look a little prettier
  repeat 10
  [
    layout-spring turtles links 0.3 (world-width / (sqrt number-of-nodes)) 1
  ]
end

to go
  if all? turtles [not infected?]
    [ stop ]
  ask turtles
  [
     set virus-check-timer virus-check-timer + 1
     if virus-check-timer >= virus-check-frequency
       [ set virus-check-timer 0 ]
  ]
  spread-virus
  do-virus-checks
  tick
end

to become-infected  ;; turtle procedure
  set infected? true
  set resistant? false
  set color red
end

to become-susceptible  ;; turtle procedure
  set infected? false
  set resistant? false
  set color blue
end

to become-resistant  ;; turtle procedure
  set infected? false
  set resistant? true
  set color gray
  ask my-links [ set color gray - 2 ]
end

to spread-virus
  ask turtles with [infected?]
    ; infecta sólo los vecinos con enlace hacia ellos
    [ ask out-link-neighbors with [not resistant?]
        [ if random-float 100 < virus-spread-chance
            [ become-infected ] ] ]
end

to do-virus-checks
  ask turtles with [infected? and virus-check-timer = 0]
  [
    if random 100 < recovery-chance
    [
      ifelse random 100 < gain-resistance-chance
        [ become-resistant ]
        [ become-susceptible ]
    ]
  ]
end


; Copyright 2008 Uri Wilensky.
; See Info tab for full copyright and license.