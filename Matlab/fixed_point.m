% funzione principale dell'algoritmo di punto fisso geometrico
function [vb, iteration] = fixed_point(lastFPOutput, vin, Rin, C, diodeA, diodeB, h, L)
    threshold = 1e-4;               %in Volts
    
    vb = lastFPOutput;
    oldVb = vb+1;
    
    iteration = 0;
    while abs(vb-oldVb) > threshold && iteration < 250
        oldVb = vb;
        
        vb = vb-summation(vb, vin, Rin, C, h, diodeA, diodeB, L)*(vb-discretized(vb, vin, Rin, C, diodeA, diodeB, h, lastFPOutput));
        
        iteration = iteration+1;
    end
end

% calcolo della funzione differenziale discretizzata
function vb = discretized(vb, vin, Rin, C, diodeA, diodeB, h, oldVb)
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
    vb = h * part1 * part2 / C + oldVb;
end

% calcolo dello jacobiano
function jc = jacobian(vb, vin, Rin, C, h, diodeA, diodeB)
    sqrtArg = 1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2;
    
    % derivata di f
    phiNum = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb);
    phiDen = diodeA.alpha*diodeA.beta*sqrt(sqrtArg);
    phi = phiNum/phiDen;
    
    derSqrtNum = sinh(diodeB.alpha*vb)*cosh(diodeB.alpha*vb);
    derSqrt = diodeB.alpha*diodeB.beta^2/diodeA.beta^2*derSqrtNum/sqrt(sqrtArg);
    psi = diodeB.alpha*sinh(diodeB.alpha*vb)*sqrt(sqrtArg)-cosh(diodeB.alpha*vb)*derSqrt;

    derPhiDen = diodeA.alpha*diodeA.beta*sqrtArg;
    derPhi = diodeB.alpha*diodeB.beta*psi/derPhiDen;
    
    fDer = -derPhi/phi^2;
    
    % derivata di g
    voltagesPartDerDen = diodeA.alpha*diodeA.beta*sqrt(sqrtArg);
    voltagesPartDer = -diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)/voltagesPartDerDen-1;
    
    gDer = voltagesPartDer/Rin-2*diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb);
    
    % f
    squareRoot = diodeA.alpha*diodeA.beta*sqrt(sqrtArg);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
    f = squareRoot/denominator;
    
    % g
    va = asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha;
    voltagesPart = (vin-va-vb)/Rin;
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    g = voltagesPart-diodePart;

    % derivata
    jc = h*(fDer*g+f*gDer)/C;
end

% calcolo della sommatoria
function sum = summation(vb, vin, Rin, C, h, diodeA, diodeB, L)
    %se l = 0 allora s = 1
    sum = 1;
    power = 1;
    if L > 0
        jc = jacobian(vb, vin, Rin, C, h, diodeA, diodeB);
    end
    
    if L > 50
        sum = 1/(1-jc);
    else
        for l = 1:L
            power = power*jc;
            
            sum = sum+power;
        end
    end
end