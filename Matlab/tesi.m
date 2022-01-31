diodeA.alpha = 1/(2*23e-3);         %23mV
diodeA.beta = 2.52e-9;              %2.52nA
diodeB.alpha = 1/(2*23e-3);         %23mV
diodeB.beta = 2.52e-9;              %2.52nA

Rin = 1e3;                          %1kOhm
C = 100e-9;                         %100nF

freq = 2;                          %Onde al secondo
time = 2;
amplitude = 1;
phase = 0;

sampleRate=50;                      %almeno freq*2 (Shannon)

samples = time*sampleRate;

input = zeros(1, samples);
output = zeros(1, samples);

for t = 0:samples
    input(t+1) = amplitude*sin(2*pi/samples*freq*t+phase);
    
%    if input(t+1) < 0
%        input(t+1) = -amplitude;
%    else
%        input(t+1) = amplitude;
%    end
    
    if t <= 1
        vb = 0;
    else
        vb = output(t-1);
    end

    output(t+1) = fixed_point(vb, input(t+1), Rin, C, diodeA, diodeB);
end

plot(0:samples, input);
hold on
plot(0:samples, output, "--");
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