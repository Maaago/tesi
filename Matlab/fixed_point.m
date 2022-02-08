function [vb] = fixed_point(lastIterationOutput, vin, Rin, C, diodeA, diodeB, T)
    threshold = 1e-4;
    
    vb = lastIterationOutput;
    oldVb = vb+1;
    
    iteration = 0;
    while abs(vb-oldVb) > threshold && iteration < 250        
        oldVb = vb;
        
        c = common(vb, vin, Rin, diodeA, diodeB);
        vb = vb-summation(C, c)*(vb-discretized(C, T, lastIterationOutput, c));
        
        iteration = iteration+1;
    end
end

% function vb = discretized(vb, oldVb, vin, Rin, C, diodeA, diodeB, T)
%     %part1
%     squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2);
%     denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
%     part1 = squareRoot/denominator;
%     
%     %part2
%     voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
%     diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
%     part2 = voltagesPart-diodePart;
%     
%     %result
%     vb = T/C * part1 * part2 + oldVb;
% end

function vb = discretized(C, T, oldVb, c)
    vb = T/C * c + oldVb;
end

function vb = common(vb, vin, Rin, diodeA, diodeB)
    %part1
    squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
    part1 = squareRoot/denominator;
    
    %part2
    voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    part2 = voltagesPart-diodePart;
    
    %result
    vb = part1 * part2;
end

function s = summation(C, c)
    L = 10000;
    
    %se l = 0 allora s = 1
    s = 1;
    p = 1;
    j = jacobian(C, c);
    
    for l = 1:L
        p = p*j;
        
        s = s+p;
    end
end

function j = jacobian(C, c)
    j = C * c;
end

% function j = jacobian(vb, vin, Rin, C, diodeA, diodeB)
%     %part1
%     squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2);
%     denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
%     part1 = squareRoot/denominator;
%     
%     %part2
%     voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
%     diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
%     part2 = voltagesPart-diodePart;
%     
%     %result
%     j = C * part1 * part2;
% end