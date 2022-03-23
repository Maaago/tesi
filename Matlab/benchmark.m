diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 100;                         %in Hz
time = 0.02;                        %in secondi
amplitude = 2.9;                    %in Volt
phase = 0*3.14;                     %in radianti

sampleRate = 192000;                 %in Hz
T = 1/sampleRate;
samples = time*sampleRate+1;
input = zeros(1, samples);

input = amplitude*generator(T, freq, phase, samples, "sine");

maxL = 50;
rep = 1;

% % Tempo d'esecizione
% times = zeros(1, maxL+1);
% for L = 0:maxL    
%     f = @() process(input, Rin, C, diodeA, diodeB, T, L);
%     
%     times(L+1) = 0;
%     for t = 1:rep
%         times(L+1) = times(L+1)+timeit(f)*1000;
%     end
%     times(L+1) = times(L+1)/rep;
%     
%     disp(L/maxL*100+"%");
% end
% 
% figure;
% plot(0:maxL, times);
% xlabel("L", "FontSize", 14);
% ylabel("Tempo [ms]", "FontSize", 14);

% % Numero iterazioni
% L = 50;
% [~, iterations] = process(input, Rin, C, diodeA, diodeB, T, L);
% 
% figure;
% plot(0:T*1000:time*1000, iterations);
% xlabel("Tempo [ms]", "FontSize", 14);
% ylabel("Iterazioni", "FontSize", 14);

% % Media iterazioni
% range = 1;%0:maxL
% rangeSize = size(range, 2);
% iterationsAvg = zeros(1, rangeSize);
% i = 1;
% for L = range
%     [output, newIterations] = process(input, Rin, C, diodeA, diodeB, T, L);
%     
%     iterationsAvg = iterationsAvg+newIterations;
%     
%     disp(i/rangeSize*100+"%");
%    
%     i = i+1;
% end
% 
% iterationsAvg = round(iterationsAvg/rangeSize);
% 
% figure;
% hold on
% yyaxis right
% inputPlot = plot(0:T*1000:time*1000, input);
% outputPlot = plot(0:T*1000:time*1000, output);
% ylabel("Ampiezza [V]", "FontSize", 14);
% yyaxis left
% iterationsPlot = plot(0:T*1000:time*1000, iterationsAvg, ".");
% ylim([0 max(iterationsAvg)+1])
% ylabel("Media iterazioni", "FontSize", 14);
% hold off
% xlabel("Tempo [ms]", "FontSize", 14);
% legend([iterationsPlot, inputPlot, outputPlot], "Iterazioni", "Input", "Output");
% grid on

% Media iterazioni
% nella tesi: A=2.0V, L={0,1,2,3,4,5,10,20,50, inf}
range = 0:21;%[0 1 2 5 10 25 50];%0:maxL
rangeSize = size(range, 2);
iterationsAvg = zeros(1, rangeSize);
i = 1;
for L = range
    [output, newIterations] = process(input, Rin, C, diodeA, diodeB, T, L);
    
    iterationsAvg(i) = sum(newIterations, "all")/samples;
    
    disp(i/rangeSize*100+"%");
    
    i = i+1;
end

figure;
plot(range, iterationsAvg, "*r", "MarkerSize", 10);
ylabel("Numero medio di iterazioni", "FontSize", 14);
xlabel("L", "FontSize", 14);
grid on