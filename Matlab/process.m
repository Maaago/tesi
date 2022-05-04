% applicazione il metodo numerico a tutti i sample
function [output, iterations, jcs] = process(input, Rin, C, diodeA, diodeB, T, L)
    samples = size(input, 2);

    output = zeros(1, samples);
    iterations = zeros(1, samples);
    
    jcs = zeros(1, samples);
    
    lastFPOutput = 0;
    for t = 1:samples
        [output(t), lastFPOutput, iterations(t), jcs(t)] = capacitor_voltage(lastFPOutput, input(t), Rin, C, diodeA, diodeB, T, L);
    end
end

% calcolo di Vout
function [vout, vb, iterations, maxJc] = capacitor_voltage(lastFPOutput, vin, Rin, C, diodeA, diodeB, T, L)
    [vb, iterations, maxJc] = fixed_point(lastFPOutput, vin, Rin, C, diodeA, diodeB, T, L);
    
    va = asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha;
    vout = va+vb;
end