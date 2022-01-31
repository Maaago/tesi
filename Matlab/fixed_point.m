function [vb] = fixed_point(lastIterationOutput, vin, Rin, C, diodeA, diodeB)
    threshold = 1e-4;
    
    vb = lastIterationOutput;
    oldVb = vb+1;
    
    iteration = 0;
    disp("iteration");
    while abs(vb-oldVb) > threshold && iteration < 250
        iteration = iteration+1;
        disp(iteration);
        
        
%         xMin = -10;
%         xMax = 10;
%         y = zeros(1, abs(xMin)+xMax);
%         for x=xMin:xMax
%             y(x-xMin+1) = nuDiscretized(x, oldVb, vin, Rin, C, diodeA, diodeB);
%         end
%         plot(xMin:xMax, y);
%         hold on
%         plot(double(oldVb), double(nuDiscretized(oldVb, oldVb, vin, Rin, C, diodeA, diodeB)), 'r*');
%         plot(double(vb), double(nuDiscretized(vb, oldVb, vin, Rin, C, diodeA, diodeB)), 'r*');
%         hold off
        
        
        oldVb = vb;
        
        vb = vb-summation(vb, vin, Rin, C, diodeA, diodeB)*(vb-nuDiscretized(vb, lastIterationOutput, vin, Rin, C, diodeA, diodeB));
    end
end

% function y = gHoffprime(v)
% if(v<0)
%     y = 0;
% else
%     y = 0.17*4*v.^3;
% end
% end
% 
% function y = gHoff(v)
% y = 0.17*(0.5*sign(v)+0.5).*v.^4;
% end
% 
% function vb = nuDiscretized(vb, oldVb, vin, R, C, diodeA, diodeB)
%     sample_rate = 44100;
%     T = 1 / (sample_rate);
%     
%     vb = (T/R/C*vin + oldVb + T/C*(gHoffprime(vb)+gHoffprime(-vb))*vb - T/C*(gHoff(vb)-gHoff(-vb))) / (1 + T/R/C + T/C*gHoffprime(vb) + T/C*gHoffprime(-vb));
% end

function vb = nuDiscretized(vb, oldVb, vin, Rin, C, diodeA, diodeB)
    sample_rate = 44100;
    T = 1 / (sample_rate);
    
    %part1
    squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))^2);
    denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
    part1 = squareRoot/denominator;
    
    %part2
    voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
    diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
    part2 = voltagesPart-diodePart;
    
    %oldVb = 0;
    
    %result
    vb = T/C * part1 * part2 + oldVb;
    
%     if isnan(squareRoot)
%         throw(MException("fixed_point:root:nan","squareRoot is NaN"));
%     end
%     if isinf(squareRoot)
%         throw(MException("fixed_point:root:inf","squareRoot is Inf"));
%     end
%     if isnan(denominator)
%         throw(MException("fixed_point:denominator:nan","denominator is NaN"));
%     end
%     if isinf(denominator)
%         throw(MException("fixed_point:denominator:inf","denominator is Inf"));
%     end
%     if isnan(part1)
%         throw(MException("fixed_point:part1:nan","part1 is NaN"));
%     end
%     if isinf(part1)
%         throw(MException("fixed_point:part1:inf","part1 is Inf"));
%     end
%     if isnan(voltagesPart)
%         throw(MException("fixed_point:voltagesPart:nan","voltagesPart is NaN"));
%     end
%     if isinf(voltagesPart)
%         throw(MException("fixed_point:voltagesPart:inf","voltagesPart is Inf"));
%     end
%     if isnan(diodePart)
%         throw(MException("fixed_point:diodePart:nan","diodePart is NaN"));
%     end
%     if isinf(diodePart)
%         throw(MException("fixed_point:diodePart:inf","diodePart is Inf"));
%     end
%     if isnan(part2)
%         throw(MException("fixed_point:part2:nan","part2 is NaN"));
%     end
%     if isinf(part2)
%         throw(MException("fixed_point:part2:inf","part2 is Inf"));
%     end
%     if isnan(vb)
%         throw(MException("fixed_point:vb:nan","vb is NaN"));
%     end
%     if isinf(vb)
%         throw(MException("fixed_point:vb:inf","vb is Inf"));
%     end
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