#%% operations with arrays
a = [1, 2, 3] # is a column vector
b = [4, 5, 6] # is a column vector

#a*b # error

c = [4 5 6] # is a row vector

a*c
c*a

d = reshape([1 2 3 4 5 6 7 8 9], 3, 3)
d*a
#a*d # error
#%%

#%% broadcasting
a .* c
c .* a
a .* d

sin.(a)

#%%

