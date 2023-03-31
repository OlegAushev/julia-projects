include("resolver.jl")

gr()


timebase = get_timebase(10e-3, 1000e3)
ϵ, n, ω, θ = generate_mechdata(timebase, 0.0, 1000.0, 0.0)
resolver_exc, resolver_sin, resolver_cos = get_resolver_signals(timebase, θ, 10e3, 1)
sample_timepoints, sin_samples, cos_samples = sample_sincos(timebase, resolver_sin, resolver_cos, 10e3)
ω_res, θ_res = run_observer(sample_timepoints, sin_samples, cos_samples, 8000.0, 1.0)



mech_plot = plot(timebase, [ϵ, n, θ], layout=(3, 1), legend=false)
resolver_plot = plot(timebase, [resolver_exc, resolver_sin, resolver_cos])
plot(mech_plot, resolver_plot, layout=(2, 1))

scatter!(resolver_plot, sample_timepoints, sin_samples)
scatter!(resolver_plot, sample_timepoints, cos_samples)

angle_plot = plot([timebase, sample_timepoints], [θ, θ_res], lw=[4 2])
speed_plot = plot([timebase, sample_timepoints], [ω, ω_res], lw=[4 2])
plot(angle_plot, speed_plot, layout=(2,1), legend=false)
