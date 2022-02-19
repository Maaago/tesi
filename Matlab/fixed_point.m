function [vb, iteration] = fixed_point(lastFPOutput, vin, Rin, C, diodeA, diodeB, T, L)
    threshold = 1e-4;               %in Volts
    
    vb = lastFPOutput;
    oldVb = vb+1;
    
    iteration = 0;
    while abs(vb-oldVb) > threshold && iteration < 250
        oldVb = vb;
        
        j = jacobian(vb, vin, Rin, C, diodeA, diodeB);
        vb = vb-summation(j, L)*(vb-discretized(T, j, lastFPOutput));
        
        iteration = iteration+1;
    end
end

function vb = discretized(T, j, oldVb)
    % visto che lo jacobiano è identico alla funzione discretizzata tolta
    % la somma di oldVb e la moltiplicazione per T riciclo i calcoli
    % eseguiti in precedenza per ottimizzare le prestazioni
    
    vb = T * j + oldVb;
end

% function vb = jacobian_new(vb, vin, Rin, C, diodeA, diodeB)
%     %part1
%     numerator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb);
%     denominator = diodeA.alpha*diodeA.beta*sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2);
%     part1 = 1/(numerator/denominator+1);
%     
%     %part2
%     voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
%     diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
%     part2 = voltagesPart-diodePart;
%     
%     %result
%     vb = part1 * part2 / C;
% end

function vb = jacobian(vb, vin, Rin, C, diodeA, diodeB)
    %part1
    arg = diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb);
    squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+arg^2);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
    part1 = squareRoot/denominator;
    
    %part2
    va = asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha;
    voltagesPart = (vin-va-vb)/Rin;
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    part2 = voltagesPart-diodePart;
    
    %result
    vb = part1 * part2 / C;
end

function sum = summation(j, L)
    %se l = 0 allora s = 1
    sum = 1;
    power = 1;

    for l = 1:L
        power = power*j;
        
        sum = sum+power;
    end
end