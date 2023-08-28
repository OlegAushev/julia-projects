using Plots

gr()


# function get_ntc_res_steinhart_hart(T, A, B, C)
#     x = (A .- 1 ./ T) ./ C
#     y = sqrt.(((B/(3*C))^3) .+ ((x ./ 2) .^ 2))
#     R = exp.(cbrt.(y .- x ./ 2) - cbrt.(y .+ x ./ 2))
#     return R
# end


# function get_ntc_temp_steinhart_hart(R, R25, A, B, C, D)
#     tmp = A .+ B .* log.(R ./ R25) + C .* ((log.(R ./ R25)) .^ 2) + D .* ((log.(R ./ R25)) .^ 3)
#     return 1 ./ tmp
# end


function get_ntc_res(T, T0, R0, B)
    R = R0 .* exp.(B .* (1 ./ T .- 1 ./ T0))
    return R
end


function get_ntc_temp(R, T0, R0, B)
    tmp = 1/T0 .+ (1/B) .* log.(R ./ R0)
    return 1 ./ tmp
end


R25 = 4700 #5000.0
T25 = 273.0 + 25.0
B = 3435 #3433


t_ntc = collect(-10.0 : 1.0 : 125.0)
T_ntc = t_ntc .+ 273.0

R_ntc = get_ntc_res(T_ntc, T25, R25, B)
res_plot = plot(t_ntc, R_ntc, yaxis=:log, minorgrid=true, legend=false)



#####
C1 = 10E-9
freq = 1 ./ (2 * 0.69 * (R_ntc .+ 2200.0) * C1) 

freq_plot = plot(R_ntc, freq, minorgrid=true, legend=false)



R_ext = 2200.0
C_ext = 10E-9
K = 1 #0.45
tw = K * R_ext * C_ext

V_adc = 3.3 * tw .* freq 

vadc_plot = plot(V_adc, t_ntc)



adc_input = collect(0 : 0.1 : 3.0)
R_calc = 31937.0 .* exp.(-2.344 .* adc_input)
T_calc = get_ntc_temp(R_calc, T25, R25, B)
t_calc = T_calc .- 273.0
scatter!(vadc_plot, adc_input, t_calc, minorgrid=true)


#plot(res_plot, freq_plot, vadc_plot, layout=(3, 1))