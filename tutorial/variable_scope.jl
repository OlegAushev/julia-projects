#%% let
a = let
    i = 3
    i += 5
    i
end

a
#%%

#%% const
const c = 299792458

c = 300000000

#c = 2.998 * 1e8 # error
#%%

#%% modules
module ScopeTestModule
export a1
export b1
a1 = 25
b1 = 42
end # end of module

using .ScopeTestModule
a1

ScopeTestModule.b1
# ScopeTestModule.b1 = 43 # error
#%%

