using Plots, DataFrames

gr()


#%% Timebase
timelimit = 500e-3
cont_samplerate = 1000e3
cont_samplecount = Int(timelimit * cont_samplerate + 1)
cont_timebase = collect(0.0 : timelimit/(cont_samplecount-1) : timelimit)
#%%


#%% Generate accel, speed, angle
accel = DataFrame(timestamp=cont_timebase, value=zeros(length(cont_timebase)))
for i in 1:nrow(accel)
    if i < length(cont_timebase)/4
        accel.value[i] = 1000.0
    elseif i < length(cont_timebase)/2
        accel.value[i] = 2000.0
    elseif i < 3*length(cont_timebase)/4
        accel.value[i] = 0.0
    else
        accel.value[i] = -3000.0
    end
end

speed_rpm0 = 0.0
speed_rpm = DataFrame(timestamp=cont_timebase, value=zeros(length(cont_timebase)))
speed_rpm.value[1] = speed_rpm0
for i in 2:nrow(speed_rpm)
    speed_rpm.value[i] = speed_rpm.value[i-1] + accel.value[i]*(1/cont_samplerate)
end

polepairs = 4
ω = transform(speed_rpm, [:value] => (value -> (2π*polepairs/60) .* value) => [:value])

θ = DataFrame(timestamp=cont_timebase, value=zeros(length(cont_timebase)))
for i in 2:nrow(θ)
    θ.value[i] = (θ.value[i-1] + ω.value[i]*(1/cont_samplerate)) % (2π)
end

gr()
plot1 = plot(cont_timebase, [accel.value, speed_rpm.value, θ.value], layout=(3, 1), legend=false)
#%%


#%% Resolver signals
resolver_excfreq = 10e3
resolver_excampl = 1

resolver_exc = DataFrame(timestamp=cont_timebase, value=zeros(length(cont_timebase)))
for i in 1:nrow(resolver_exc)
    resolver_exc.value[i] = resolver_excampl * sin(2π*resolver_excfreq*resolver_exc.timestamp[i])
end

resolver_sin = DataFrame(timestamp=cont_timebase, value=sin.(θ.value).*resolver_exc.value)
resolver_cos = DataFrame(timestamp=cont_timebase, value=cos.(θ.value).*resolver_exc.value)

plot2 = plot(cont_timebase, [resolver_exc.value, resolver_sin.value, resolver_cos.value])
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