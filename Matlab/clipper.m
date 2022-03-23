diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 100;                         %in Hz
time = 0.02;                        %in secondi
amplitude = 20.0;                    %in Volt
phase = 0*3.14;                     %in radianti

sampleRate = 192000;                %in Hz
T = 1/sampleRate;
samples = time*sampleRate+1;

L = 51;

%for amplitude = 1.0:0.1:3.0
%   figure;

input = amplitude*generator(T, freq, phase, samples, "sine");

output = process(input, Rin, C, diodeA, diodeB, T, L);

plot(0:T:time, input);
hold on
plot(0:T:time, output, "--");
hold off

legend("Input", "Output");
xlabel("Tempo [s]", "FontSize", 14);
ylabel("Ampiezza [V]", "FontSize", 14);

%end