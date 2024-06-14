using Noise, GLMakie

samplecount = 1000
timebase = LinRange(0.0, 10.0, samplecount)

n = 60.0
ω = 2π * n / 60.0

θ_0 = 0.0
θ = Array{Float64, 1}(undef, samplecount)
θ[1] = rem2pi(θ_0, RoundDown)
for i in 1 : samplecount - 1
    θ[i+1] = rem2pi((θ[i] + ω * (timebase[i+1] - timebase[i])), RoundDown)
    
end


figure1 = Figure(size = (1500, 1000))
θ_plot = Axis(figure1[1, 1])
lines!(θ_plot, timebase, θ)
figure1
