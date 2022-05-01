diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 1000;                        %in Hz
time = 1/freq*2;                    %in secondi
amplitude = 1;                      %in Volt
phase = 0*3.14;                     %in radianti

sampleRate = 48e3;                  %in Hz
T = 1/sampleRate;
samples = time*sampleRate+1;

L = 0;

samples = round(samples);           % il risultato è già una cifra tonda, ma potrebbe essere un decimale, quindi devo fare il cast esplicito
input = amplitude*generator(T, freq, phase, samples, "sine");

output = process(input, Rin, C, diodeA, diodeB, T, L);

plot(0:T:time, input);
hold on
plot(0:T:time, output, "--");
hold off

title("Ampiezza massima: "+num2str(amplitude)+"V");
legend("Input", "Output");
xlabel("Tempo [s]", "FontSize", 14);
ylabel("Ampiezza [V]", "FontSize", 14);
set(gca,'XLim',[0 time],'YLim',[-amplitude amplitude])