#?using Plots
using CairoMakie


include("resolver.jl")


timebase = get_timebase(1000e-3, 100e3)
ϵ, n, ω, θ = generate_mechdata(timebase, 0.0, 1000.0, 0.0)
resolver_exc, resolver_sin, resolver_cos = get_resolver_signals(timebase, θ, 10e3, 1)
sample_timepoints, sin_samples, cos_samples = sample_sincos(timebase, resolver_sin, resolver_cos, 10e3)
ω_res, θ_res = run_observer(sample_timepoints, sin_samples, cos_samples, 1000.0, 1)


figure1 = Figure(resolution = (1500, 1000))

resolver_plot = Axis(figure1[1, 1])
lines!(resolver_plot, timebase, resolver_exc)
lines!(resolver_plot, timebase, resolver_sin)
lines!(resolver_plot, timebase, resolver_cos)
scatter!(resolver_plot, sample_timepoints, sin_samples)
scatter!(resolver_plot, sample_timepoints, cos_samples)

angle_plot = Axis(figure1[2, 1])
lines!(angle_plot, timebase, θ, linewidth = 4)
lines!(angle_plot, sample_timepoints, θ_res, linewidth = 2)

speed_plot = Axis(figure1[3, 1])
lines!(speed_plot, timebase, ω, linewidth = 4)
lines!(speed_plot, sample_timepoints, ω_res, linewidth = 2)

figure1
















# obsolete

#gr()
#plotlyjs()

# mech_plot = plot(timebase, [ϵ, n, θ], layout=(3, 1), legend=false)
# resolver_plot = plot(timebase, [resolver_exc, resolver_sin, resolver_cos])
# plot(mech_plot, resolver_plot, layout=(2, 1))

# scatter!(resolver_plot, sample_timepoints, sin_samples)
# scatter!(resolver_plot, sample_timepoints, cos_samples)

# acc_plot = plot(timebase, ϵ);
# angle_plot = plot([timebase, sample_timepoints], [θ, θ_res], lw=[4 2])
# speed_plot = plot([timebase, sample_timepoints], [ω, ω_res], lw=[4 2])
# plot(acc_plot, angle_plot, speed_plot, resolver_plot, layout=(4,1), legend=false, size = (1500, 1000))
