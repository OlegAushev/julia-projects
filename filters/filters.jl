using Plots, DataFrames, Random

gr()


#%% Timebase
timelimit = 10e-3
samplerate = 10e3
ts = 1/samplerate
samplecount = Int(timelimit * samplerate + 1)
timebase = collect(0.0 : timelimit/(samplecount-1) : timelimit)
#%%


#%% Input signals
inputsignal = fill.(exp(1)/(exp(1)-1), samplecount)
#inputsignal .+= rand(samplecount)


function movingavg_filter(input, windowsize)
    output = fill(0.0, length(input))
    window = fill(0.0, windowsize)
    sum = 0
    idx = 1
    
    for i in eachindex(input)
        sum = sum + input[i] - window[idx]
        window[idx] = input[i]
        idx = mod1(idx+1, windowsize)
        output[i] = sum / windowsize
    end

    return output
end

output1 = movingavg_filter(inputsignal, 10)


function exp1_filter(input, smoothfactor)
    output = fill(0.0, length(input))

    #output[1] = input[1]
    for i in filter(i -> i != 1, eachindex(input))
        output[i] = output[i-1] + smoothfactor * (input[i] - output[i-1])
    end

    return output
end

output2 = exp1_filter(inputsignal, 0.1)


function exp2_filter(input, timeconstant, ts)
    smoothfactor = ts/timeconstant
    return exp1_filter(input, smoothfactor)
end

output3 = exp2_filter(inputsignal, 0.0025, ts)


function kalman_filter(input)
    output = fill(0.0, length(input))
    coef = 0.1

    for i in filter(i -> i != length(input), eachindex(input))
        output[i+1] = coef*input[i+1] + (1-coef)*output[i]
    end

    return output
end

output4 = kalman_filter(inputsignal)


plot(timebase, [inputsignal, output1, output2, output3, output4])

#%%

