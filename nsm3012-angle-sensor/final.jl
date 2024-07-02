using Noise, GLMakie, DataStructures

modeltime = 0.2
samplecount = 100001
timebase = LinRange(0.0, modeltime, samplecount)

daq_freq = 10000.0
daq_period = 1 / daq_freq

n = 3000.0
ω = 2π * n / 60.0
pole_pairs = 4
max_angle_step = (9000.0 / 60.0) * 2π * daq_period

slow_2π_crossing = true
level_2π_crossing = true

# input signal 
input_0 = 0.0
input = Vector{Float64}(undef, samplecount)
input[1] = rem2pi(input_0, RoundDown)
for i in 1 : samplecount - 1
    input[i+1] = rem2pi((input[i] + ω * (timebase[i+1] - timebase[i])), RoundDown)
end

# add slow 0/2π-crossing
cross_time = 400e-6
level_time = 200e-6
if slow_2π_crossing
    for i in 1 : samplecount
        if input[i] > 2π - 0.01
            t = timebase[i]
            j = i + 1

            t_level_begin = rand(t : timebase[2] - timebase[1] : t + cross_time - level_time)
            t_level_end = t_level_begin + level_time

            while j <= samplecount
                if (timebase[j] - t) > cross_time
                    break
                end

                if (timebase[j] > t_level_begin) && (timebase[j] < t_level_end) && level_2π_crossing
                    input[j] = input[j-1]
                else
                    input[j] = 2π - (2π / cross_time) * (timebase[j] - t)
                end
                
                j = j + 1
            end
            i = j
        end
    end
end

# sampling & processing
daq_timebase = Vector{Float64}(undef, 0)
push!(daq_timebase, timebase[1])
sensor_angle = Vector{Float64}(undef, 0)
push!(sensor_angle, input[1])

delay = 500e-6
ndelay::Int = delay * daq_freq
sensor_angle_buffer = CircularBuffer{Float64}(ndelay)
push!(sensor_angle_buffer, 0)


cb_back = Vector{Float64}(undef, 0)
push!(cb_back, 0)
cb_front = Vector{Float64}(undef, 0)
push!(cb_front, 0)


turns = Vector{Int}(undef, 0)
push!(turns, 0)

mech_angle = Vector{Float64}(undef, 0)
push!(mech_angle, 0)
elec_angle = Vector{Float64}(undef, 0)
push!(elec_angle, 0)

mech_abs_angle = Vector{Float64}(undef, 0)
push!(mech_abs_angle, 0)
elec_abs_angle = Vector{Float64}(undef, 0)
push!(elec_abs_angle, 0)

speed_smooth = 0.01
speed_filter = Vector{Float64}(undef, 0)
push!(speed_filter, 0)


for i in 1 : samplecount
    if (timebase[i] - last(daq_timebase)) < (daq_period - 1e-12)
        continue
    else
        push!(daq_timebase, timebase[i])
        push!(sensor_angle, input[i])
        arg = input[i]

        push!(turns, last(turns))
        push!(speed_filter, last(speed_filter))
        
        sensor_bigdiff = abs(arg - sensor_angle_buffer[end]) > max_angle_step
        sensor_freeze = abs(arg - sensor_angle_buffer[1]) > length(sensor_angle_buffer) * max_angle_step
        
        push!(cb_back, sensor_angle_buffer[end])
        push!(cb_front, sensor_angle_buffer[1])
        
        push!(sensor_angle_buffer, arg)

        if sensor_bigdiff || sensor_freeze
            mech_angle_diff = last(speed_filter)/pole_pairs/daq_freq
            mech_angle_new = last(mech_angle) + mech_angle_diff
            push!(mech_angle, rem2pi(mech_angle_new, RoundNearest))
        else
            prev_mech_angle = last(mech_angle)
            push!(mech_angle, rem2pi(arg, RoundNearest))
            mech_angle_diff = last(mech_angle) - prev_mech_angle

            if abs(mech_angle_diff) > (2π - max_angle_step)
                if last(mech_angle) < 0
                    turns[end] = last(turns) + 1
                else
                    turns[end] = last(turns) - 1
                end
            elseif abs(mech_angle_diff) <= max_angle_step 
                speed_filter[end] = last(speed_filter) + speed_smooth * (pole_pairs * mech_angle_diff * daq_freq - last(speed_filter))
            end
        end

        push!(elec_angle, rem2pi(pole_pairs * last(mech_angle), RoundNearest))
        push!(mech_abs_angle, last(turns) * 2π + last(mech_angle))
        push!(elec_abs_angle, pole_pairs * last(mech_abs_angle))
    end
end


speed_rpm = speed_filter .* (60 / 2π / pole_pairs)



figure1 = Figure(size = (1500, 1000))

angle_plot = Axis(figure1[1, 1])
# lines!(angle_plot, timebase, input)
lines!(angle_plot, daq_timebase, sensor_angle)
lines!(angle_plot, daq_timebase, cb_back)
lines!(angle_plot, daq_timebase, cb_front)
lines!(angle_plot, daq_timebase, mech_angle)
# lines!(angle_plot, daq_timebase, elec_angle)

turns_plot = Axis(figure1[2, 1])
lines!(turns_plot, daq_timebase, turns)

abs_plot = Axis(figure1[3, 1])
lines!(abs_plot, daq_timebase, mech_abs_angle)
lines!(abs_plot, daq_timebase,  elec_abs_angle)

speed_plot = Axis(figure1[4, 1])
lines!(speed_plot, daq_timebase, speed_rpm)

DataInspector(figure1)
figure1







