function [maxPitch, minPitch, meanPitch, meanMaxPitch, meanMinPitch]  = find_5_Pitch(audio, audio_fs, percentage)

% The default percentage is 0.2
if percentage < 0
    k = 0.2; 
else
    k = percentage;
end

% Calculate the 5 indicator
[myPitch, idx] = pitch(audio, audio_fs, ...
            'Method','PEF', ...
            'WindowLength',round(audio_fs*0.08), ...
            'OverlapLength',round(audio_fs*(0.08-0.01)), ...
            'Range',[15,1200], ...
            'MedianFilterLength',3);

maxPitch = max(myPitch);
minPitch = min(myPitch);
meanPitch = mean(myPitch);

% Sort the pitch from largest to smallest
Pitch_sorted_descend = sort(myPitch,'descend');

% Calculate the number of samples to take in the top 95%~75%
num_descend = length(Pitch_sorted_descend);
num_to_take_descend = round(num_descend * k);
max_start = 1+round(num_descend*0.05);
max_end = max_start+ num_to_take_descend;

% Take the largest top k% pitch and calculate mean value
max_series = Pitch_sorted_descend(max_start:max_end);
meanMaxPitch = mean(max_series(:),1);

% Sort the pitch from samllest to largest
Pitch_sorted_ascend = sort(myPitch,'ascend');

% Calculate the number of samples to take in the top 95%~75%
num_ascend = length(Pitch_sorted_ascend);
num_to_take_ascend = round(num_ascend * k);
min_start = 1+round(num_ascend*0.05);
min_end = min_start+ num_to_take_ascend;

% Take the smallest top k% pitch and calculate mean value
min_series = Pitch_sorted_ascend(min_start:min_end);
meanMinPitch = mean(min_series(:),1);

% Test and plot area ======================================================              
%t = (idx - 1)/audio_fs;
%plot(t,myPitch)
%title('有經過預處理的');
%xlabel('Time (s)')
%ylabel('Pitch (Hz)')
% Test (print the result)
% fprintf('Highest Pitch: %f Hz\n', maxPitch);
% fprintf('Lowest Pitch: %f Hz\n', minPitch);
% fprintf('Average Pitch: %f Hz\n', meanPitch);
% fprintf('Average High Pitch: %f Hz\n', meanMaxPitch);
% fprintf('Average Low Pitch: %f Hz\n', meanMinPitch);
%==========================================================================


end