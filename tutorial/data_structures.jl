#%% Vectors
a = [1, 2, 3, 4, 5]
b = [1.2, 3, 4, 5]
c = ["Hello", "my name is", "Oleg"]

append!(a, 6.)
typeof(a)

d = Int[1, 2, 3, 4, 5]
#%%

#%% Matrices
mat1 = [1 2 3; 4 5 6]
println(mat1)
typeof(mat1)
#%%

#%% N-dimensional arrays
table = zeros(2, 3, 4)
for k in 1:4
    for j in 1:3
        for i in 1:2
            table[i,j,k] = i*j*k
        end
    end
end

table
#%%

#%% Slices
e = a[2:5]

mat2 = reshape([i for i in 1:16], 4, 4)
mat3 = mat2[1:3, 2:3]

mat4 = reshape([i+j for i in 1:3 for j in 1:4], 3, 4)
#%%

#%% Views
v1 = [1, 2, 3]
v2 = v1
v2[2] = 42
v1
v3 = copy(v1)
v3[2] = 43
v1

#%% Tuples
t1 = (1, 2, 3)
t2 = 1, 2, 3

a, b, c = t1
println("$a $b $c")

function return_multiple()
    return 42, 43, 44
end

a, b, c = return_multiple()
println("$a $b $c")
#%%

#%% Splatting
function splat_me(a, b, c)
    return a*b*c
end

tuple1 = (1, 2, 3)

splat_me(tuple1...)

#%%

#%% Named Tuples
named_tuple_1 = (a = 1, b = "Hello")
named_tuple_1[:b]

named_tuple_2 = NamedTuple{(:a, :b)}((2, "hello"))
named_tuple_2[:b]
#%%

#%% Dictionaries
person1 = Dict("Name" => "Oleg", "Phone" => 12345, "Shoe-size" => 44)
person2 = Dict("Name" => "Liliia", "Phone" => 54321, "Shoe-size" => 41)
address_book = Dict("Oleg" => person1)
address_book["Liliia"] = person2
address_book
#%%

