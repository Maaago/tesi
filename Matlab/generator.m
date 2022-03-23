function samples = generator(T, freq, phase, num_samples, type)
    samples = zeros(1, num_samples);
    t = 0:num_samples-1;

    switch type
        case "sine"
            samples = sin(2*pi*T*freq*t+phase);
        case "triangle"
            %samples = rem(2*pi*T*freq*t, 2*pi*T)+phase;
            
            %samples = 1-(abs(samples)/T);

            samples = sawtooth(2*pi*T*freq*t+phase, 1/2);
        case "saw"
            samples = sawtooth(2*pi*T*freq*t+phase, 0);
        case "square"
            samples = square(2*pi*T*freq*(t-1)+phase);
            
%             samples = sin(2*pi*T*freq*t+phase);
%             
%             for i=1:num_samples
%                 if(samples(i) > 0)
%                     samples(i) = 1;
%                 else
%                     samples(i) = -1;
%                 end
%             end
        otherwise
            samples(t) = 1.0;
    end
end
