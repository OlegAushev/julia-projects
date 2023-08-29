#%%
function plus_two(x)
    return x + 2
end

plus_two_inline(x) = x + 2

println(plus_two(1))
println(plus_two_inline(3))
#%%

#%%
using Pkg
Pkg.add("QuadGK")
using QuadGK

f(x, y, z) = (x^2 + 2y)*z

quadgk(x->f(x, 42, 4), 3, 4)

arg(x) = f(x, 42, 4)
quadgk(arg, 3, 4)
#%%

#%%
function say_hi()
    println("Hi! Void function!")
    return
end
#%%

#%%
function my_weight(weight_on_earth, g = 9.81)
    return weight_on_earth * g / 9.81
end

my_weight(70)
my_weight(70, 3.72)
#%%

#%%
function my_long_function(a, b=2; c, d=3)
    return a + b + c + d
end

my_long_function(1, 2, c=3)
my_long_function(1, 2, c=3, d=4)
my_long_function(1, 2, d=4, c=3)
#my_long_function(1,2,d=4) error
#%%

