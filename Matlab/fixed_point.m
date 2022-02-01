function [vb] = fixed_point(lastIterationOutput, vin, Rin, C, diodeA, diodeB, T)
    threshold = 1e-4;
    
    vb = lastIterationOutput;
    oldVb = vb+1;
    
    iteration = 0;
    while abs(vb-oldVb) > threshold && iteration < 250        
        oldVb = vb;
        
        vb = vb-summation(vb, vin, Rin, C, diodeA, diodeB)*(vb-discretized(vb, lastIterationOutput, vin, Rin, C, diodeA, diodeB, T));
        
        iteration = iteration+1;
    end
end

function vb = discretized(vb, oldVb, vin, Rin, C, diodeA, diodeB, T)
    %part1
    squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
    part1 = squareRoot/denominator;
    
    %part2
    voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    part2 = voltagesPart-diodePart;
    
    %result
    vb = T/C * part1 * part2 + oldVb;
end

function s = summation(vb, vin, Rin, C, diodeA, diodeB)
    L = 1;
    
    s = 0;
    for l = 0:L
        s = s+jacobian(vb, vin, Rin, C, diodeA, diodeB)^l;
    end
end

function j = jacobian(vb, vin, Rin, C, diodeA, diodeB)
    %part1
    squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
    part1 = squareRoot/denominator;
    
    %part2
    voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    part2 = voltagesPart-diodePart;
    
    %result
    j = C * part1 * part2;
end