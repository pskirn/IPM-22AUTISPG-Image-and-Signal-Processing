% Load the audio file
[audio, fs] = audioread('audio_16.wav');
%sound(audio, fs);

% Split the audio into two halves
halfway = round(length(audio) / 2);
first_half = audio(1:halfway);
second_half = audio(halfway+1:end);

% Step 1: Median Filter on the second half (Noise Filter)
window_size = 5;  % Adjust window size if needed
filtered_second_half = medfilt1(second_half, window_size);

% Step 2: Correct Structural Distortion in Second Half
stretch_factor = 1; % Example time stretch factor, adjust as needed
stretched_second_half = stretchAudio(filtered_second_half, stretch_factor);

% Step 3: Volume Normalization for Second Half
volume_scaling = max(abs(first_half)) / max(abs(stretched_second_half));
normalized_second_half = stretched_second_half * volume_scaling;

% Step 4: Combine the first half (unchanged) with the enhanced second half
enhanced_audio = [first_half; normalized_second_half(1:end)]; 

% Plot the enhanced audio
figure;
plot(enhanced_audio);
title('Enhanced Audio Signal');
xlabel('Sample');
ylabel('Amplitude');

% Save the enhanced audio
audiowrite('enhanced_audio_filtered_stretched.wav', enhanced_audio, fs);

% Play the final enhanced audio
sound(enhanced_audio, fs);
