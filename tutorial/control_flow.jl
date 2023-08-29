#%% if-else
function absolute(x)
    if x >= 0
        return x
    else
        return -x
    end
end

if (1 < 3) & (3 < 4)
    println("Hi!")
end

x = 42
if x < 1
    println("$x < 1")
elseif x < 100
    println("$x < 100")
else
   println("$x is big")
end
#%%

#%% for-loop
for i in 1:4
    println(i^2)
end

persons = ["Oleg", "Liliia"]
for person in persons
    println("Hi, $person.")
end
#%%

#%% break, continue
for i in 1:4
    if i > 2
        println()
        break
    else
        print("$i ")
    end
end

for i in 1:4
    if i % 2 == 0
        continue
    else
        println(i)
    end
end
#%%

#%% while
function while_test()
    i = 0
    while (i < 3)
        println(i)
        i += 1
    end
end
while_test()
#%%

#%% enumerate
x = ["a", "b", "c"]
for couple in enumerate(x)
    println(couple)
end

arr1 = collect(1:10)
arr2 = zeros(10)
for (i, element) in enumerate(arr1)
    arr2[i] = element^2
end
println(arr2)
#%%