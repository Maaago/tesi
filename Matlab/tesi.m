diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 100;                         %in Hz
time = 0.02;
amplitude = 1;
phase = 0;

sampleRate = 44100;
T = 1/sampleRate;

samples = time*sampleRate;
input = zeros(1, samples);
output = zeros(1, samples);

for t = 0:samples
    input(t+1) = amplitude*sin(2*pi/sampleRate*freq*t+phase);
        
    if t <= 1
        vb = 0;
    else
        vb = output(t-1);
    end

    output(t+1) = fixed_point(vb, input(t+1), Rin, C, diodeA, diodeB, T);
    
    va = T*asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*output(t+1)))/diodeA.alpha;
    output(t+1) = va+output(t+1);
    
    %disp(t/samples*100+"%");
end

plot(0:T:time, input);
hold on
plot(0:T:time, output, "--");
hold off

legend("input", "output")
xlabel("tempo [s]", "FontSize", 14);
ylabel("ampiezza [V]", "FontSize", 14);