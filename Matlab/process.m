function [output, iterations] = process(input, samples, Rin, C, diodeA, diodeB, T, L)
    output = zeros(1, samples);
    iterations = zeros(1, samples);
    
    for t = 0:samples
        if t < 1
            lastIterationOutput = 0;
        else
            lastIterationOutput = output(t);
        end

        [output(t+1), iterations(t+1)] = capacitor_voltage(lastIterationOutput, input(t+1), Rin, C, diodeA, diodeB, T, L);
    end
end

function [vout, iterations] = capacitor_voltage(lastIterationOutput, vin, Rin, C, diodeA, diodeB, T, L)
    [vb, iterations] = fixed_point(lastIterationOutput, vin, Rin, C, diodeA, diodeB, T, L);
    
    vout = T*asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha+vb;
end