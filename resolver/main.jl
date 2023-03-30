include("resolver.jl")

gr()


mech_data = generate_mechdata(100e-3, 1000e3, 0.0, 0.0)
mech_plot = plot(mech_data.timepoint, [mech_data.ϵ, mech_data.n, mech_data.θ], layout=(3, 1), legend=false)


resolver_signals = get_resolver_signals(mech_data, 10e3, 1)
resolver_plot = plot(resolver_signals.timepoint, [resolver_signals.exc, resolver_signals.sin, resolver_signals.cos])
plot(mech_plot, resolver_plot, layout=(2, 1))


sincos_samples = sample_sincos(resolver_signals, 10e3)
scatter!(resolver_plot, sincos_samples.timepoint, sincos_samples.sin)
scatter!(resolver_plot, sincos_samples.timepoint, sincos_samples.cos)


observer_data = run_observer(sincos_samples, 4000.0, 1.0)


angle_plot = plot([mech_data.timepoint, observer_data.timepoint], [mech_data.θ, observer_data.θ], lw=[4 2])
speed_plot = plot([mech_data.timepoint, observer_data.timepoint], [mech_data.ω, observer_data.ω], lw=[4 2])
plot(angle_plot, speed_plot, layout=(2,1), legend=false)
