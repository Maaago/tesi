diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 100;                         %in Hz
time = 1/freq*2;                    %in secondi
amplitude = 1.4;                    %in Volt
phase = 0*3.14;                     %in radianti

sampleRate = 48e3;                  %in Hz
T = 1/sampleRate;
samples = time*sampleRate+1;

L = 50;
Ls = [0 1 2 3 4 5 10 20 50 60];

minAmplitude = 1.0;
%maxAmplitude = minAmplitude;
step = 0.1;
steps = 4;
maxAmplitude = minAmplitude+step*(steps-1);
%w = 3;
%h = 3;
s = sqrt(steps);
w = ceil(s);
h = w;
if s-floor(s) < 0.5
    if s-floor(s) > 0
        h = h-1;
    end
end

samples = round(samples);
input_normalized = generator(T, freq, phase, samples, "sine");

%[input, Fs] = audioread("/Users/francesco/Desktop/PTT-20210106-WA0003-1.mp3");
%input = input(:, 1);           % Take just one channel
%samples = size(input, 1);
%time = T*(samples-1);
%input_normalized = input/max(abs(input));

%for L = Ls
%    figure;
    
for amplitude = minAmplitude:step:maxAmplitude
	input = amplitude*input_normalized;

    [output, ~, jcs] = process(input, Rin, C, diodeA, diodeB, T, L);

    p = round((amplitude-minAmplitude+step)*1/step);
    subplot(w, h, p);
    plot(0:T:time, input);
    hold on
    plot(0:T:time, output, "--");
    hold off

    title("Ampiezza massima: "+num2str(amplitude)+"V");
    legend("Input", "Output");
    xlabel("Tempo [s]", "FontSize", 14);
    ylabel("Ampiezza [V]", "FontSize", 14);
    set(gca,'XLim',[0 time],'YLim',[-amplitude amplitude])
end
%end