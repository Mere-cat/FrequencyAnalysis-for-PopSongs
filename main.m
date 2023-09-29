clear;
clc;
close all;
% Read audio
inputAudio = 'sounds/music.wav'; 
[audio, audio_fs] = audioread(inputAudio);

% Pre-process
flatAudio = preprocess(audio, audio_fs);

percentage = 0.2; %You can choose the percentage you what to define as high pitch section or low pitch section

% Calculate 5 Indicator
% Use the processed audio
tic;
fprintf("Do Pitch calculate...");
[maxPitch, minPitch, meanPitch, meanMaxPitch, meanMinPitch]  = find_5_Pitch(flatAudio, audio_fs, percentage);
toc
% Use the non-processed (original) audio
% [maxPitch, minPitch, meanPitch, meanMaxPitch, meanMinPitch]  = find_5_Pitch(audio, audio_fs, percentage);


disp('Result for find_5_Pitch');
fprintf('Highest Pitch: %f Hz\n', maxPitch);
fprintf('Lowest Pitch: %f Hz\n', minPitch);
fprintf('Average Pitch: %f Hz\n', meanPitch);
fprintf('Average High Pitch: %f Hz\n', meanMaxPitch);
fprintf('Average Low Pitch: %f Hz\n', meanMinPitch);