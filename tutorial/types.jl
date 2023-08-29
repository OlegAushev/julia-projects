abstract type Person
end

abstract type Musician <: Person
end

mutable struct Rockstar <: Musician
    name::String
    instrument::String
    bandname::String
    headband_color::String
    instruments_played::Int
end

struct ClassicMusician <: Musician
    name::String
    instrument::String
end

mutable struct Programmer <: Person
    name::String
    sleephours::Float64
    favourite_language::String
end


oleg = Programmer("Oleg", 7, "C++")
oleg.name
oleg.sleephours
oleg.favourite_language
oleg.sleephours = 8

oleg_musician = ClassicMusician("Oleg", "Cello")
# musician.instrument = "Violin" # immutable concrete type

liliia = Rockstar("Liliia", "Voice", "CPI", "red", 2)


function introduceme(person::Person)
    println("Hello, my name is $(person.name).")
end

function introduceme(person::Musician)
    println("Hello, my name is $(person.name) and I play $(person.instrument).")
end

function introduceme(person::Rockstar)
    if person.instrument == "Voice"
        println("Hello, my name is $(person.name) and I sing.")
    else
        println("Hello, my name is $(person.name) and I play $(person.instrument).")
    end

    println("My band name is $(person.bandname) and my favourite headband colour is $(person.headband_color)!")
end

introduceme(oleg)
introduceme(oleg_musician)
introduceme(liliia)


mutable struct MyData
    x::Float64
    x2::Float64
    y::Float64
    z::Float64
    function MyData(x::Float64, y::Float64)
        x2 = x^2
        z = x2 + y
        new(x, x2, y, z)
    end
end

MyData(2.0, 3.0)


mutable struct MyData2{T<:Real}
    x::T
    x2::T
    y::T
    z::Float64
    function MyData2{T}(x::T, y::T) where {T<:Real}
        x2 = x^2
        z = x2 + y
        new(x, x2, y, z)
    end
end

MyData2{Float64}(2.0, 3.0)
MyData2{Int}(2, 3)





