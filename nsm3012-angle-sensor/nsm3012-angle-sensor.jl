using Noise, GLMakie

modeltime = 1.0
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

# sampling
daq_timebase = Vector{Float64}(undef, 0)
input_sample = Vector{Float64}(undef, 0)
mech_angle = Vector{Float64}(undef, 0)

push!(daq_timebase, timebase[1])
push!(input_sample, input[1])
push!(mech_angle, rem2pi(input[1], RoundNearest))

for i in 1 : samplecount
    if (timebase[i] - last(daq_timebase)) < daq_period - 1e-12
        continue
    else
        push!(daq_timebase, timebase[i])
        push!(input_sample, input[i])
        push!(mech_angle, rem2pi(input[i], RoundNearest))
    end
end

# processing
turns = zeros(length(daq_timebase))

elec_angle = Vector{Float64}(undef, length(daq_timebase))
elec_angle[1] = 0
mech_abs_angle = Vector{Float64}(undef, length(daq_timebase))
mech_abs_angle[1] = 0
elec_abs_angle = Vector{Float64}(undef, length(daq_timebase))
elec_abs_angle[1] = 0

speed_smooth = 0.01
speed_filter = Vector{Float64}(undef, length(daq_timebase))
speed_filter[1] = 0


# Wrong Approach
# elec_angle = rem2pi.(pole_pairs .* mech_angle, RoundNearest)

# input_smooth = 0.05
# input_filter = Vector{Float64}(undef, length(daq_timebase))
# input_filter[1] = 0
# for i in 2 : length(input_filter)
#     input_filter[i] = input_filter[i-1] + input_smooth * (input_sample[i] - input_filter[i-1])
# end

# for i in 2 : length(daq_timebase)
#     turns[i] = turns[i-1]
    
#     if (abs(mech_angle[i] - mech_angle[i-1])) >= (2π - max_angle_step)
#         if (input_filter[i] < π/2) || (input_filter[i] > 3π/2)
#             mech_angle[i] = rem2pi(mech_angle[i-1] + (speed_filter[i-1] / daq_freq), RoundNearest)
#         else
#             if mech_angle[i] < 0
#                 turns[i] = turns[i-1] + 1
#             else
#                 turns[i] = turns[i-1] - 1
#             end
#         end
#     end
    
#     mech_abs_angle[i] = turns[i] * 2π + mech_angle[i]
#     elec_abs_angle[i] = pole_pairs * mech_abs_angle[i]
    
#     diff = elec_abs_angle[i] - elec_abs_angle[i-1]
#     if abs(diff) <= (max_angle_step * pole_pairs)
#         speed_filter[i] = speed_filter[i-1] + speed_smooth * (diff * daq_freq - speed_filter[i-1])
#     else 
#         speed_filter[i] = speed_filter[i-1]
#     end
# end


# Approach I
# input_smooth = 0.05
# input_filter = Vector{Float64}(undef, length(daq_timebase))
# input_filter[1] = 0
# for i in 2 : length(input_filter)
#     input_filter[i] = input_filter[i-1] + input_smooth * (input_sample[i] - input_filter[i-1])
# end

# for i in 2 : length(daq_timebase)
#     turns[i] = turns[i-1]
    
#     if (abs(input_sample[i] - input_sample[i-1])) > max_angle_step
#         mech_angle[i] = rem2pi(mech_angle[i-1] + (speed_filter[i-1] / pole_pairs / daq_freq), RoundNearest)
#     elseif (abs(mech_angle[i] - mech_angle[i-1])) >= (2π - max_angle_step)
#         if (input_filter[i] < π/2) || (input_filter[i] > 3π/2)
#             mech_angle[i] = rem2pi(mech_angle[i-1] + (speed_filter[i-1] / pole_pairs / daq_freq), RoundNearest)
#         else
#             if mech_angle[i] < 0
#                 turns[i] = turns[i-1] + 1
#             else
#                 turns[i] = turns[i-1] - 1
#             end
#         end
#     end
    
#     elec_angle[i] = rem2pi(pole_pairs * mech_angle[i], RoundNearest)
#     mech_abs_angle[i] = turns[i] * 2π + mech_angle[i]
#     elec_abs_angle[i] = pole_pairs * mech_abs_angle[i]
    
#     diff = elec_abs_angle[i] - elec_abs_angle[i-1]
#     if abs(diff) <= (max_angle_step * pole_pairs)
#         speed_filter[i] = speed_filter[i-1] + speed_smooth * (diff * daq_freq - speed_filter[i-1])
#     else 
#         speed_filter[i] = speed_filter[i-1]
#     end
# end


# Approach II
step = zeros(length(daq_timebase))
input_filter = zeros(length(daq_timebase))
delay = 500e-6
ndelay::Int = delay * daq_freq
for i in ndelay+1 : length(input_filter)
    input_filter[i] = input_sample[i-ndelay]
end

for i in 2 : length(daq_timebase)
    turns[i] = turns[i-1]
    speed_filter[i] = speed_filter[i-1]

    mech_angle_diff = mech_angle[i] - mech_angle[i-1]

    if (abs(input_sample[i] - input_sample[i-1])) > max_angle_step
        mech_angle[i] = rem2pi(mech_angle[i-1] + (speed_filter[i-1] / pole_pairs / daq_freq), RoundNearest)
    elseif abs(input_sample[i] - input_filter[i]) > 5 * max_angle_step
        mech_angle[i] = rem2pi(mech_angle[i-1] + (speed_filter[i-1] / pole_pairs / daq_freq), RoundNearest)
    elseif abs(mech_angle_diff) >= (2π - max_angle_step)
        if mech_angle[i] < 0
            turns[i] = turns[i-1] + 1
        else
            turns[i] = turns[i-1] - 1
        end
    elseif abs(mech_angle_diff) <= max_angle_step
        speed_filter[i] = speed_filter[i-1] + speed_smooth * (pole_pairs * mech_angle_diff * daq_freq - speed_filter[i-1])
    # elseif (abs(mech_angle_diff) > 10*max_angle_step) && (abs(mech_angle_diff) < (2π - max_angle_step))
        # mech_angle[i] = rem2pi(mech_angle[i-1] + (speed_filter[i-1] / pole_pairs / daq_freq), RoundNearest)
    end

    step[i] = mech_angle[i] - mech_angle[i-1]
    
    elec_angle[i] = rem2pi(pole_pairs * mech_angle[i], RoundNearest)
    mech_abs_angle[i] = turns[i] * 2π + mech_angle[i]
    elec_abs_angle[i] = pole_pairs * mech_abs_angle[i]
    
    # diff = elec_abs_angle[i] - elec_abs_angle[i-1]
    # if abs(diff) <= (max_angle_step * pole_pairs)
    #     speed_filter[i] = speed_filter[i-1] + speed_smooth * (diff * daq_freq - speed_filter[i-1])
    # else 
    #     speed_filter[i] = speed_filter[i-1]
    # end
end

speed_rpm = speed_filter .* (60 / 2π / pole_pairs)



figure1 = Figure(size = (1500, 1000))

angle_plot = Axis(figure1[1, 1])
lines!(angle_plot, timebase, input)
lines!(angle_plot, daq_timebase, input_filter)
lines!(angle_plot, daq_timebase, mech_angle)
lines!(angle_plot, daq_timebase, elec_angle)

turns_plot = Axis(figure1[2, 1])
lines!(turns_plot, daq_timebase, turns)

abs_plot = Axis(figure1[3, 1])
lines!(abs_plot, daq_timebase, mech_abs_angle)
lines!(abs_plot, daq_timebase,  elec_abs_angle)

speed_plot = Axis(figure1[4, 1])
lines!(speed_plot, daq_timebase, speed_rpm)

DataInspector(figure1)
figure1
