diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 100;                         %in Hz
time = 0.02;                        %in secondi
amplitude = 1.0;                    %in Volt
phase = 0*3.14;                     %in radianti

sampleRate = 44100;                 %in Hz
T = 1/sampleRate;

samples = time*sampleRate+1;
input = zeros(1, samples);

for t = 1:samples
    input(t) = amplitude*sin(2*pi/sampleRate*freq*(t-1)+phase);
end

maxL = 100;
rep = 10;

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
% L = 0;
% [~, iterations] = process(input, Rin, C, diodeA, diodeB, T, L);
% 
% figure;
% plot(0:T*1000:time*1000, iterations);
% xlabel("Tempo [ms]", "FontSize", 14);
% ylabel("Iterazioni", "FontSize", 14);

% % Media iterazioni
% iterationsAvg = zeros(1, samples);
% for L = 0:maxL
%     [~, newIterations] = process(input, Rin, C, diodeA, diodeB, T, L);
%     
%     iterationsAvg = iterationsAvg+newIterations;
%     
%     disp(L/maxL*100+"%");
% end
% 
% iterationsAvg = iterationsAvg/(maxL+1);
% 
% figure;
% hold on
% yyaxis right
% inputPlot = plot(0:T*1000:time*1000, input);
% ylabel("Ampiezza [V]", "FontSize", 14);
% yyaxis left
% iterationsPlot = plot(0:T*1000:time*1000, iterationsAvg, ".");
% ylim([0 max(iterationsAvg)+1])
% ylabel("Media iterazioni", "FontSize", 14);
% hold off
% xlabel("Tempo [ms]", "FontSize", 14);
% legend([iterationsPlot, inputPlot], "Iterazioni", "Input");
% grid on

% % Media iterazioni
% iterationsAvg = zeros(1, maxL+1);
% single = 1.0;
% for L = 0:maxL
%     [~, newIterations] = process(single, Rin, C, diodeA, diodeB, T, L);
%     
%     %iterationsAvg(L+1) = sum(newIterations, "all")/samples;
%     iterationsAvg(L+1) = newIterations;
%     
%     disp(L/maxL*100+"%");
% end
% 
% figure;
% plot(0:maxL, iterationsAvg);
% ylabel("Numero medio di iterazioni", "FontSize", 14);
% xlabel("L", "FontSize", 14);
% grid on
