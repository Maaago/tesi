diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 1000;                        %in Hz
time = 1/freq*2;                   %in secondi
amplitude = 1.6;                    %in Volt
phase = 0*3.14;                     %in radianti

sampleRate = 48e3;                  %in Hz
T = 1/sampleRate;
samples = time*sampleRate+1;

samples = round(samples);
input = amplitude*generator(T, freq, phase, samples, "sine");
%input = amplitude*input_normalized;

%[input, Fs] = audioread("/Users/francesco/Desktop/test.mp3");
%input = input(:, 1);           % Take just one channel
%samples = size(input, 1);
%time = T*(samples-1);

maxL = 60;
rep = 10;

% % Tempo d'esecizione
% times = zeros(1, maxL+1);
% for L = 0:maxL    
%     f = @() process(input, Rin, C, diodeA, diodeB, T, L);
%     
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
% range = 0:maxL;%[3 50 51];%0:maxL;
% rangeSize = size(range, 2);
% iterationsAvg = zeros(1, samples);
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

% % Media iterazioni
% range = [0 1 2 3 4 5 10 20 50 60];%[3 50 51];%0:maxL;
% rangeSize = size(range, 2);
% iterationsAvg = zeros(1, rangeSize);
% i = 1;
% for L = range
%     [output, newIterations, ~] = process(input, Rin, C, diodeA, diodeB, T, L);
%     
%     iterationsAvg(i) = sum(newIterations, "all")/samples;
%     
% %      if iterationsAvg(i) < 1 %|| L < 10
% %          iterationsAvg(i) = 0;
% %      end
%     
%     disp(i/rangeSize*100+"%");
%     
%     i = i+1;
% end
% 
% figure;
% rangeSize = size(range, 2);
% labels = cell(rangeSize);
% for i = 1:rangeSize
%     labels{i} = range(i);
% end
% labels{rangeSize} = "Infinito";
% 
% plot(range, iterationsAvg, "*r", "MarkerSize", 10);
% xticks(range);
% xticklabels(labels);
% %ylim([min(iterationsAvg)-0.5 max(iterationsAvg)+0.5])
% ylim([0 max(iterationsAvg)+0.5])
% ylabel("Numero medio di iterazioni", "FontSize", 14);
% xlabel("L", "FontSize", 14);
% grid on


% Valore dello jacobiano
range = [1 5 20 50];%[3 50 51];%0:maxL;
rangeSize = size(range, 2);
iterationsAvg = zeros(1, rangeSize);
legendItems = cell(0, rangeSize+2);
colors = lines(rangeSize+2);
i = 1;
figure;
hold on;
yyaxis left
c = colors(1:rangeSize, 1:3);
set(gca, 'LineStyleOrder', '-', 'ColorOrder', colors(1:rangeSize, 1:3))
for L = range
    [output, ~, jcs] = process(input, Rin, C, diodeA, diodeB, T, L);
    
    plot(0:T:time, jcs);
    
    legendItems{i} = "Derivata per L = "+num2str(L);
    
    disp(i/rangeSize*100+"%");
    
    i = i+1;
    
    if L == 1
        output1 = output;
    end
end
ylabel("Valore massimo della derivata", "FontSize", 14);
yyaxis right
set(gca, 'LineStyleOrder', '-', 'ColorOrder', colors(rangeSize+1:rangeSize+2, 1:3))
plot(0:T:time, output1);
legendItems{i} = "Output per L = 1";
plot(0:T:time, output);
legendItems{i+1} = "Output per L = 50";
ylabel("Ampiezza [V]", "FontSize", 14);
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
hold off;

title("Ampiezza massima: "+num2str(amplitude)+"V");
legend(legendItems);
xlabel("Tempo [s]", "FontSize", 14);