diodeA.alpha = (2*23*10^(-3));    %23mV
diodeA.beta = 2.52*10^(-9);         %2.52nA
diodeB.alpha = (2*23*10^(-3));    %23mV
diodeB.beta = 2.52*10^(-9);         %2.52nA

Rin = 1*10^3;                       %1kOhm
C = 100*10^(-9);                    %100nF

freq = 1/100;
time = 5;
amplitude = 0.9;
phase = 0;

samples = time/freq;

input = zeros(1, samples);
output = zeros(1, samples);

for t = 1:samples
    input(t) = amplitude*sin(2*pi*freq*(t-1)+phase);
    
    if input(t) < 0
        input(t) = -amplitude;
    else
        input(t) = amplitude;
    end

    output(t) = fixed_point(input(t), Rin, C, diodeA, diodeB);
end

plot(1:samples, input);
hold on
plot(1:samples, output, "--");
hold off

legend("input", "output")

%recObj = audiorecorder;
%info = audiodevinfo;

%disp('Start speaking.')
%recordblocking(recObj, 5);
%disp('End of Recording.');

%play(recObj);
%disp('End play.');

%y = getaudiodata(recObj);
%plot(y)