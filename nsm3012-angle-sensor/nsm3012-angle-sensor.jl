using Noise, GLMakie

modeltime = 0.1
samplecount = 100000
timebase = LinRange(0.0, modeltime, samplecount)

n = 3000.0
ω = 2π * n / 60.0
pole_pairs = 4
max_angle_step = (7200.0 / 60.0) * 2π * (modeltime / samplecount)


# input signal 
input_0 = 0.0
input = Array{Float64, 1}(undef, samplecount)
input[1] = rem2pi(input_0, RoundDown)
for i in 1 : samplecount - 1
    input[i+1] = rem2pi((input[i] + ω * (timebase[i+1] - timebase[i])), RoundDown)
end

# add noise
for i in 1 : samplecount
    if input[i] > 2π - 0.01
        t = timebase[i]
        j = i + 1
        while j <= samplecount
            if (timebase[j] - t > 300e-6)
                break
            end
            input[j] = 2π - (2π / 300e-6) * (timebase[j] - t)
            j = j + 1
        end
        i = j
    end
end


# processing
mech_angle = rem2pi.(input, RoundNearest)
elec_angle = rem2pi.(4 .* input, RoundNearest) 
turns = zeros(samplecount)

# filter input, approach I
smooth = 0.005
input_filter = Array{Float64, 1}(undef, samplecount)
input_filter[1] = 0
for i in 2 : samplecount
    input_filter[i] = input_filter[i-1] + smooth * (input[i] - input_filter[i-1])
end



# detect -π/π-crossing
for i in 2 : samplecount
    if (abs(mech_angle[i] - mech_angle[i-1])) > (2π - 0.1)
        if mech_angle[i] < 0
            turns[i] = turns[i-1] + 1
        else
            turns[i] = turns[i-1] - 1
        end
    else
        turns[i] = turns[i-1]
    end
end



figure1 = Figure(size = (1500, 1000))
angle_plot = Axis(figure1[1, 1])
lines!(angle_plot, timebase, input)
lines!(angle_plot, timebase, input_filter)
lines!(angle_plot, timebase, mech_angle)
lines!(angle_plot, timebase, elec_angle)

turns_plot = Axis(figure1[2, 1])
lines!(turns_plot, timebase, turns)

figure1
