function audio  = preprocess(myAudio, audio_fs)
% 0. Pre-process the input audio===========================================
% 0.1 Stereo to mono
% 0.2 Remove background signal
% 0.3 Bandpass filter
%==========================================================================
% 0.1 Stereo to mono
tic;
fprintf("Do Stereo to Mono...");
audio = stereo2mono(myAudio);
toc

% 0.2 Remove background signal
tic;
fprintf("Do Remove background signal...");
foreground = audio - repet.original(audio, audio_fs);
audio = foreground;
toc

% 0.3 Bandpass filter specify passband frequencies of 20 Hz and 20000 Hz
tic;
fprintf("Do Bandpass filter...");
audio = bandpass(audio,[20 20000],audio_fs); 
toc

end