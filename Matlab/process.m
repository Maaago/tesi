function [output, iterations] = process(input, Rin, C, diodeA, diodeB, T, L)
    samples = size(input, 2);

    output = zeros(1, samples);
    iterations = zeros(1, samples);
    
    for t = 1:samples
        if t == 1
            lastIterationOutput = 0;
        else
            lastIterationOutput = output(t-1);
        end

        [output(t), iterations(t)] = capacitor_voltage(lastIterationOutput, input(t), Rin, C, diodeA, diodeB, T, L);
    end
end

function [vout, iterations] = capacitor_voltage(lastIterationOutput, vin, Rin, C, diodeA, diodeB, T, L)
    [vb, iterations] = fixed_point(lastIterationOutput, vin, Rin, C, diodeA, diodeB, T, L);
    
    vout = T*asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha+vb;
end