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

L = 10000;

for t = 0:samples
    input(t+1) = amplitude*sin(2*pi/sampleRate*freq*t+phase);
end

output = process(input, samples, Rin, C, diodeA, diodeB, T, L);

plot(0:T:time, input);
hold on
plot(0:T:time, output, "--");
hold off

legend("Input", "Output");
xlabel("Tempo [s]", "FontSize", 14);
ylabel("Ampiezza [V]", "FontSize", 14);