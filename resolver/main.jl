using Plots, DataFrames

gr()


#%% Timebase
timelimit = 1e-3
samplerate_cont = 1000e3
ts_cont = 1/samplerate_cont
samplecount_cont = Int(timelimit * samplerate_cont + 1)
timebase_cont = collect(0.0 : timelimit/(samplecount_cont-1) : timelimit)
#%%


#%% Generate accel, speed, angle
df_mech = DataFrame();
df_mech.timepoint = timebase_cont;

df_mech[!, :ϵ] .= 0.0
for i in 1:nrow(df_mech)
    if i < nrow(df_mech)/4
        df_mech.ϵ[i] = 1000.0
    elseif i < nrow(df_mech)/2
        df_mech.ϵ[i] = 2000.0
    elseif i < 3*nrow(df_mech)/4
        df_mech.ϵ[i] = 0.0
    else
        df_mech.ϵ[i] = -3000.0
    end
end

n_init = 8000.0
df_mech[!, :n] .= 0.0
df_mech.n[1] = n_init
for i in 2:nrow(df_mech)
    df_mech.n[i] = df_mech.n[i-1] + df_mech.ϵ[i-1]*ts_cont
end

polepairs = 4
df_mech[!, :ω] = df_mech[:, :n] .* (2π*polepairs/60)

θ_init = 0.0
df_mech[!, :θ] .= 0.0
df_mech.θ[1] = θ_init;
for i in 2:nrow(df_mech)
    df_mech.θ[i] = (df_mech.θ[i-1] + df_mech.ω[i-1]*ts_cont) % (2π)
end

gr()
plot1 = plot(df_mech.timepoint, [df_mech.ϵ, df_mech.n, df_mech.θ], layout=(3, 1), legend=false)
#%%


#%% Resolver signals
df_resolver = DataFrame();
df_resolver.timepoint = timebase_cont;

resolver_excfreq = 10e3
resolver_excampl = 1

df_resolver[!, :exc] .= 0.0
for i in 1:nrow(df_resolver)
    df_resolver.exc[i] = resolver_excampl * sin(2π*resolver_excfreq*df_resolver.timepoint[i])
end

df_resolver[!, :sin] = sin.(df_mech.θ) .* df_resolver[:, :exc]
df_resolver[!, :cos] = cos.(df_mech.θ) .* df_resolver[:, :exc]

plot2 = plot(df_resolver.timepoint, [df_resolver.exc, df_resolver.sin, df_resolver.cos])
plot(plot1, plot2, layout=(2, 1))
#%%


#%% Downsampling SIN and COS
adc_samplerate = 10e3
adc_samplecount = Int(timelimit * adc_samplerate + 1)
adc_sin = getindex(resolver_sin, Int(cont_samplerate/adc_samplerate/4+1):Int(cont_samplerate/adc_samplerate):nrow(resolver_sin), :)
scatter!(plot2, adc_sin.timestamp, adc_sin.value)

adc_cos = getindex(resolver_cos, Int(cont_samplerate/adc_samplerate/4+1):Int(cont_samplerate/adc_samplerate):nrow(resolver_cos), :)
scatter!(plot2, adc_cos.timestamp, adc_cos.value)
#%%


#%% Observer
observer_timebase = adc_sin.timestamp

ts = observer_timebase[2] - observer_timebase[1]
naturalfreq = 4000.0
dampingfactor = 1.6
K1 = naturalfreq^2
K2 = 2 * dampingfactor / naturalfreq

error = DataFrame(timestamp=observer_timebase, value=zeros(length(observer_timebase)));
acc2 = DataFrame(timestamp=observer_timebase, value=zeros(length(observer_timebase)))
Ω = DataFrame(timestamp=observer_timebase, value=zeros(length(observer_timebase)))
ϕ = DataFrame(timestamp=observer_timebase, value=zeros(length(observer_timebase)))

for n in 2:length(observer_timebase)
    Ω.value[n] = Ω.value[n-1] + K1*ts*error.value[n-1]
    acc2.value[n] = (acc2.value[n-1] + ts*Ω.value[n-1]) % (2π)
    ϕ.value[n] = (K2*Ω.value[n] + acc2.value[n]) % (2π)
    error.value[n] = adc_sin.value[n]*cos(ϕ.value[n]) - adc_cos.value[n]*sin(ϕ.value[n])
end

# for n in 1:length(observer_timebase)-1
#     Ω.value[n+1] = Ω.value[n] + K1*ts*error.value[n]
#     acc2.value[n+1] = (acc2.value[n] + ts*Ω.value[n]) % (2π)
#     ϕ.value[n+1] = (K2*Ω.value[n+1] + acc2.value[n+1]) % (2π)
#     error.value[n+1] = adc_sin.value[n+1]*cos(ϕ.value[n+1]) - adc_cos.value[n+1]*sin(ϕ.value[n+1])
# end
#%%

plot_angle = plot([θ.timestamp, ϕ.timestamp], [θ.value, ϕ.value], lw=[4 2])
plot_speed = plot([ω.timestamp, Ω.timestamp], [ω.value, Ω.value], lw=[4 2])
plot(plot2, plot_angle, plot_speed, layout=(3,1), legend=false)