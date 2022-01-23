function [vb] = fixed_point(vin, Rin, C, diodeA, diodeB)
    tollerance = 0.0001;

    vb = vin;
    oldVb = vb-1;
    
    iteration = 0;
    disp("iteration");
    while (vb-oldVb) > tollerance
        iteration = iteration+1;
        disp(iteration);
        
        newVb = vb-summation(vb, vin, Rin, C, diodeA, diodeB)*(vb-nuDiscretized(vb, oldVb, vin, Rin, C, diodeA, diodeB));

        oldVb = vb;
        vb = newVb;
    end
end

function vb = nuDiscretized(vb, oldVb, vin, Rin, C, diodeA, diodeB)
    %part1
    squareRoot = sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeA.alpha*vb))^2);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeA.alpha*vb)+diodeA.alpha*diodeA.beta*squareRoot;
    part1 = squareRoot/denominator;
    
    %part2
    voltagesPart = 1/Rin*(vin-1/diodeA.alpha*asinh(diodeB.beta/diodeA.beta*sinh(diodeA.alpha*vb)));
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    part2 = voltagesPart-diodePart;
    
    %result
    vb = diodeA.alpha*diodeA.beta/C * part1 * part2 + oldVb;
end

function s = summation(vb, vin, Rin, C, diodeA, diodeB)
    L = 0;
    
    s = 0;
    for l = 0:L
        s = s+jacobian(vb, vin, Rin, C, diodeA, diodeB)^l;
    end
end

function j = jacobian(vb, vin, Rin, C, diodeA, diodeB)
    %part1
    squareRoot = sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeA.alpha*vb))^2);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeA.alpha*vb)+diodeA.alpha*diodeA.beta*squareRoot;
    part1 = squareRoot/denominator;
    
    %part2
    voltagesPart = 1/Rin*(vin-1/diodeA.alpha*asinh(diodeB.beta/diodeA.beta*sinh(diodeA.alpha*vb)));
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    part2 = voltagesPart-diodePart;
    
    j = diodeA.alpha*diodeA.beta/C * part1 * part2;
end