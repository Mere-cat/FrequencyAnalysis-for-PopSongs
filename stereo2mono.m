function monoAudio  = stereo2mono(myAudio)

[m, n] = size(myAudio); % gives dimensions of array where n is the number of stereo channels
if n == 2
    monoAudio = myAudio(:, 1) + myAudio(:, 2); % sum(y, 2) also accomplishes this
    peakAmp = max(abs(monoAudio)); 
    monoAudio = monoAudio/peakAmp;
    % check the L/R channels for orig. peak Amplitudes
    peakL = max(abs(myAudio(:, 1)));
    peakR = max(abs(myAudio(:, 2))); 
    maxPeak = max([peakL peakR]);
    % apply x's original peak amplitude to the normalized mono mixdown 
    monoAudio = monoAudio*maxPeak;
    
else
    monoAudio = myAudio; %it is stereo so we will return it as is (e.g., for additional processing)
end