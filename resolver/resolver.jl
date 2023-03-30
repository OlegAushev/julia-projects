using Plots, DataFrames


function generate_mechdata(timelimit, samplerate, θ_init, n_init)
    samplecount = Int(timelimit * samplerate + 1)
    ts = 1/samplerate
    
    timepoint = collect(0.0 : timelimit/(samplecount-1) : timelimit)
    
    ϵ = zeros(samplecount)
    ϵ_list = [2000.0, 4000.0, 0.0, -6000.0]
    for i in 1:samplecount
        if i < samplecount/4
            ϵ[i] = ϵ_list[1]
        elseif i < samplecount/2
            ϵ[i] = ϵ_list[2]
        elseif i < 3*samplecount/4
            ϵ[i] = ϵ_list[3]
        else
            ϵ[i] = ϵ_list[4]
        end
    end

    n = zeros(samplecount)
    n[1] = n_init
    for i in 2:samplecount
        n[i] = n[i-1] + ϵ[i-1]*ts
    end

    polepairs = 4
    ω = n .* (2π*polepairs/60)

    θ = zeros(samplecount)
    θ[1] = rem2pi(θ_init, RoundNearest)
    for i in 2:samplecount
        θ[i] = rem2pi((θ[i-1] + ω[i-1]*ts), RoundNearest)
    end

    mechdata = DataFrame()
    mechdata.timepoint = timepoint
    mechdata.ϵ = ϵ
    mechdata.n = n
    mechdata.ω = ω
    mechdata.θ = θ
    
    return mechdata
end


function get_resolver_signals(mechdata, excfreq, excampl)
    resolver_signals = DataFrame()
    resolver_signals.timepoint = mechdata.timepoint

    resolver_signals[!, :exc] .= 0.0
    for i in 1:nrow(resolver_signals)
        resolver_signals.exc[i] = excampl * sin(2π*excfreq*resolver_signals.timepoint[i])
    end

    resolver_signals[!, :sin] = sin.(mechdata.θ) .* resolver_signals[:, :exc]
    resolver_signals[!, :cos] = cos.(mechdata.θ) .* resolver_signals[:, :exc]

    return resolver_signals
end


function sample_sincos(resolver_signals, samplerate)
    resolver_samplerate = 1 / (resolver_signals.timepoint[2] - resolver_signals.timepoint[1])
    samples = getindex(resolver_signals,
                       Int(resolver_samplerate/samplerate/4):Int(resolver_samplerate/samplerate):nrow(resolver_signals),
                       [:timepoint, :sin, :cos])
    return samples
end


function run_observer(sincos_samples, naturalfreq, dampingfactor)
    observer_data = DataFrame()

    observer_data.timepoint = sincos_samples.timepoint
    observer_data[!, :error] .= 0.0
    observer_data[!, :acc2] .= 0.0
    observer_data[!, :ω] .= 0.0
    observer_data[!, :θ] .= 0.0

    K1 = naturalfreq^2
    K2 = 2 * dampingfactor / naturalfreq

    ts = sincos_samples.timepoint[2] - sincos_samples.timepoint[1]

    for k in 1:nrow(observer_data)-1
        observer_data.ω[k+1] = observer_data.ω[k] + K1*ts*observer_data.error[k]
        observer_data.acc2[k+1] = rem2pi((observer_data.acc2[k] + ts*observer_data.ω[k]), RoundNearest)
        observer_data.θ[k+1] = rem2pi((K2*observer_data.ω[k+1] + observer_data.acc2[k+1]), RoundNearest)
        observer_data.error[k+1] = sincos_samples.sin[k+1]*cos(observer_data.θ[k+1]) - sincos_samples.cos[k+1]*sin(observer_data.θ[k+1])
    end

    return observer_data
end

