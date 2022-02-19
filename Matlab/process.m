function [output, iterations] = process(input, Rin, C, diodeA, diodeB, T, L)
    samples = size(input, 2);

    output = zeros(1, samples);
    iterations = zeros(1, samples);
    
    lastFPOutput = 0;
    for t = 1:samples
        [output(t), lastFPOutput, iterations(t)] = capacitor_voltage(lastFPOutput, input(t), Rin, C, diodeA, diodeB, T, L);
    end
end

function [vout, vb, iterations] = capacitor_voltage(lastFPOutput, vin, Rin, C, diodeA, diodeB, T, L)
    [vb, iterations] = fixed_point(lastFPOutput, vin, Rin, C, diodeA, diodeB, T, L);
    
    va = asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha;
    vout = va+vb;
end