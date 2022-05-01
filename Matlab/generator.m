% generatore di funzioni
function samples = generator(T, freq, phase, num_samples, type)
    samples = zeros(1, num_samples);
    t = 0:num_samples-1;

    switch type
        case "sine"
            samples = sin(2*pi*T*freq*t+phase);
        case "triangle"
            samples = sawtooth(2*pi*T*freq*t+phase, 1/2);
        case "saw"
            samples = sawtooth(2*pi*T*freq*t+phase, 0);
        case "square"
            samples = square(2*pi*T*freq*(t-1)+phase);
        case "noise"
            samples = wgn(num_samples, 1, 0);
            
            samples = samples/max(abs(samples));
            samples = samples';
        otherwise
            samples(t) = 1.0;
    end
end
