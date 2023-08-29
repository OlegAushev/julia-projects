using Pkg
Pkg.add("SpecialFunctions")
using SpecialFunctions # or using SpecialFunctions: gamma, sinint

gamma(3)
sinint(5)


module MyModule

export func2

function func2(x)
    return func1(x) + a
end

a = 42
function func1(x)
    return x^2    
end

end # end of module


import .MyModule

MyModule.func2(1)



