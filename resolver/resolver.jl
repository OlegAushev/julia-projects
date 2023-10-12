using Noise


function get_timebase(timelimit, samplerate)
    samplecount = Int(timelimit * samplerate) + 1
    timebase = collect(0.0 : timelimit/(samplecount-1) : timelimit)
    return timebase
end


function generate_mechdata(timebase, θ_init, n_init, ϵ_init)
    samplecount = length(timebase)
    ts = timebase[2] - timebase[1]
    
    ϵ = Array{Float64, 1}(undef, samplecount)
    for i in eachindex(ϵ)
        if i < samplecount/2
            ϵ[i] = ϵ_init
        else
            ϵ[i] = -ϵ_init
        end
    end

    # sic!
    ϵ = ϵ .+ 1000 .* sin.(2π * 10 .* timebase) .+ 1000000 .* sin.(2π * 17 .* timebase);

    n = Array{Float64, 1}(undef, samplecount)
    n[1] = n_init
    for k in 1:samplecount-1
        n[k+1] = n[k] + ϵ[k]*ts
    end

    polepairs = 4
    ω = n .* (2π*polepairs/60)

    θ = Array{Float64, 1}(undef, samplecount)
    θ[1] = rem2pi(θ_init, RoundNearest)
    for k in 1:samplecount-1
        θ[k+1] = rem2pi((θ[k] + ω[k]*ts), RoundNearest)
    end

    return ϵ, n, ω, θ
end


function get_resolver_signals(timebase, θ, excfreq, excampl)
    resolver_exc = excampl .* sin.(2π*excfreq .* timebase)
    resolver_sin = sin.(θ) .* resolver_exc
    resolver_cos = cos.(θ) .* resolver_exc

    # sic!
    resolver_sin_noise = add_gauss(resolver_sin, 0.1)
    resolver_cos_noise = add_gauss(resolver_cos, 0.1)

    return resolver_exc, resolver_sin_noise, resolver_cos_noise
end


function sample_sincos(timebase, resolver_sin, resolver_cos, samplerate)
    resolver_samplerate = 1 / (timebase[2] - timebase[1])

    sample_timepoints = getindex(timebase,
            round(Int, resolver_samplerate/samplerate/4) : round(Int, resolver_samplerate/samplerate) : length(timebase))
    
    sin_samples = getindex(resolver_sin,
            round(Int, resolver_samplerate/samplerate/4) : round(Int, resolver_samplerate/samplerate) : length(timebase))
    
    cos_samples = getindex(resolver_cos,
            round(Int, resolver_samplerate/samplerate/4) : round(Int, resolver_samplerate/samplerate) : length(timebase))
    
    return sample_timepoints, sin_samples, cos_samples
end


function run_observer(sample_timepoints, sin_samples, cos_samples, naturalfreq, dampingfactor)
    samplecount = length(sample_timepoints)
    ts = sample_timepoints[2] - sample_timepoints[1]

    error = Array{Float64, 1}(undef, samplecount)
    error[1] = 0
    acc2 = Array{Float64, 1}(undef, samplecount)
    acc2[1] = 0
    ω = Array{Float64, 1}(undef, samplecount)
    ω[1] = 0
    θ = Array{Float64, 1}(undef, samplecount)
    θ[1] = 0

    K1 = naturalfreq^2
    K2 = 2 * dampingfactor / naturalfreq

    for k in 1:samplecount-1
        ω[k+1] = ω[k] + K1*ts*error[k]
        acc2[k+1] = rem2pi((acc2[k] + ts*ω[k]), RoundNearest)
        θ[k+1] = rem2pi((K2*ω[k+1] + acc2[k+1]), RoundNearest)
        error[k+1] = sin_samples[k+1]*cos(θ[k+1]) - cos_samples[k+1]*sin(θ[k+1])
    end

    return ω, θ
end
