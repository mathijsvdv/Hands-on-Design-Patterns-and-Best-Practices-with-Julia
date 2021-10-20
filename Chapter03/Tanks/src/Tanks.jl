module Tanks

export M4Sherman

"M4Sherman is a pivotal WW2 tank from the US."
mutable struct M4Sherman

    "power status: true = on, false = off"
    power::Bool 

    "current direction in radians"
    direction::Float64

    "current position coordinate (x,y)"
    position::Tuple{Float64, Float64} 

    wheels::Tuple{Symbol, Symbol}

end

# Import generic functions
import Vehicle: power_on!, power_off!, turn!, move!, position, engage_wheels!, has_wheels

# Implementation of Vehicle interface

function power_on!(t::M4Sherman)
    t.power = true
    println("Powered on: ", t, " ready to go!")
    nothing
end

function power_off!(t::M4Sherman)
    t.power = false
    println("Powered off: ", t)
    nothing
end

function turn!(t::M4Sherman, direction)
    t.direction = direction
    println("Now barreling towards ", direction, ": ", t)
    nothing
end

function move!(t::M4Sherman, distance) 
    x, y = t.position
    dx = round(distance * cos(t.direction), digits = 2)
    dy = round(distance * sin(t.direction), digits = 2)
    t.position = (x + dx, y + dy)
    println("Moved (", dx, ",", dy, "): ", t)
    nothing
end

function position(t::M4Sherman)
    t.position
end

has_wheels(t::M4Sherman) = true

function engage_wheels!(t::M4Sherman)
    println("Making mark with both wheels")
    nothing
end

end # module
