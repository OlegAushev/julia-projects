using Plots, DataFrames

gr()


#%% Timebase
timelimit = 1000e-3
samplerate_cont = 1000e3
ts_cont = 1/samplerate_cont
samplecount_cont = Int(timelimit * samplerate_cont + 1)
timebase_cont = collect(0.0 : timelimit/(samplecount_cont-1) : timelimit)
#%%


#%% Generate accel, speed, angle
df_mech = DataFrame()
df_mech.timepoint = timebase_cont

df_mech[!, :ϵ] .= 0.0
ϵ_list = [2000.0, 4000.0, 0.0, -6000.0]
for i in 1:nrow(df_mech)
    if i < nrow(df_mech)/4
        df_mech.ϵ[i] = ϵ_list[1]
    elseif i < nrow(df_mech)/2
        df_mech.ϵ[i] = ϵ_list[2]
    elseif i < 3*nrow(df_mech)/4
        df_mech.ϵ[i] = ϵ_list[3]
    else
        df_mech.ϵ[i] = ϵ_list[4]
    end
end

n_init = 0.0
df_mech[!, :n] .= 0.0
df_mech.n[1] = n_init
for i in 2:nrow(df_mech)
    df_mech.n[i] = df_mech.n[i-1] + df_mech.ϵ[i-1]*ts_cont
end

polepairs = 4
df_mech[!, :ω] = df_mech[:, :n] .* (2π*polepairs/60)

θ_init = 0
df_mech[!, :θ] .= 0.0
df_mech.θ[1] = rem2pi(θ_init, RoundNearest)
for i in 2:nrow(df_mech)
    df_mech.θ[i] = rem2pi((df_mech.θ[i-1] + df_mech.ω[i-1]*ts_cont), RoundNearest)
end

plot_mech = plot(df_mech.timepoint, [df_mech.ϵ, df_mech.n, df_mech.θ], layout=(3, 1), legend=false)
#%%


#%% Resolver signals
df_resolver = DataFrame()
df_resolver.timepoint = timebase_cont

resolver_excfreq = 10e3
resolver_excampl = 1

df_resolver[!, :exc] .= 0.0
for i in 1:nrow(df_resolver)
    df_resolver.exc[i] = resolver_excampl * sin(2π*resolver_excfreq*df_resolver.timepoint[i])
end

df_resolver[!, :sin] = sin.(df_mech.θ) .* df_resolver[:, :exc]
df_resolver[!, :cos] = cos.(df_mech.θ) .* df_resolver[:, :exc]

plot_resolver = plot(df_resolver.timepoint, [df_resolver.exc, df_resolver.sin, df_resolver.cos])
plot(plot_mech, plot_resolver, layout=(2, 1))
#%%


#%% Downsampling SIN and COS
df_adc = DataFrame()

samplerate_adc = 10e3
ts_adc = 1/samplerate_adc
samplecount_adc = Int(timelimit * samplerate_adc + 1)


df_adc = getindex(df_resolver, Int(samplerate_cont/samplerate_adc/4):Int(samplerate_cont/samplerate_adc):nrow(df_resolver), [:timepoint, :sin, :cos])
scatter!(plot_resolver, df_adc.timepoint, df_adc.sin)
scatter!(plot_resolver, df_adc.timepoint, df_adc.cos)
#%%


#%% Observer
df_observer = DataFrame()

df_observer.timepoint = df_adc.timepoint
df_observer[!, :error] .= 0.0
df_observer[!, :acc2] .= 0.0
df_observer[!, :ω] .= 0.0
df_observer[!, :θ] .= 0.0

naturalfreq = 4000.0
dampingfactor = 1.0
K1 = naturalfreq^2
K2 = 2 * dampingfactor / naturalfreq

for n in 2:nrow(df_observer)
    df_observer.ω[n] = df_observer.ω[n-1] + K1*ts_adc*df_observer.error[n-1]
    df_observer.acc2[n] = rem2pi((df_observer.acc2[n-1] + ts_adc*df_observer.ω[n-1]), RoundNearest)
    df_observer.θ[n] = rem2pi((K2*df_observer.ω[n] + df_observer.acc2[n]), RoundNearest)
    df_observer.error[n] = df_adc.sin[n]*cos(df_observer.θ[n]) - df_adc.cos[n]*sin(df_observer.θ[n])
end

plot_angle = plot([df_mech.timepoint, df_observer.timepoint], [df_mech.θ, df_observer.θ], lw=[4 2])
plot_speed = plot([df_mech.timepoint, df_observer.timepoint], [df_mech.ω, df_observer.ω], lw=[4 2])
plot(plot_angle, plot_speed, layout=(2,1), legend=false)
#%%
