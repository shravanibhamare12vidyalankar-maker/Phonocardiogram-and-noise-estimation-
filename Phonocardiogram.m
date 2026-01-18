%% Phonocardiogram Spectrogram and Heart Rate
clc; clear; close all;

filename = 'Patient Information Sheet.xlsx';
data = readtable(filename, 'VariableNamingRule', 'preserve');

disp('Available columns:');
disp(data.Properties.VariableNames);

% --- Extract numeric PCG signal ---
numericCols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
pcg = table2array(data(:, numericCols));
pcg = pcg(:);   % ensure column vector

% --- Sampling rate ---
fs = 1000;  % adjust if known

% --- Filter ---
[b, a] = butter(4, [20 200]/(fs/2), 'bandpass');
pcg_filt = filtfilt(b, a, pcg);

% --- Spectrogram ---
N = length(pcg_filt);
window = min(256, N);
noverlap = floor(window/2);
nfft = max(256, 2^nextpow2(window));

figure;
[s, f, t] = spectrogram(pcg_filt, window, noverlap, nfft, fs, 'yaxis');
imagesc(t, f, 20*log10(abs(s)+eps));
axis xy; ylim([0 500]);
colormap(jet); colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrogram of Phonocardiogram');

% --- Heart rate detection ---
pcg_filt = double(pcg_filt(:));
env = abs(hilbert(pcg_filt));
env_smooth = smooth(env, 50);
env_smooth = double(env_smooth(:));

if isempty(env_smooth) || length(env_smooth) < 100
    warning('Phonocardiogram signal too short or empty — skipping peak detection.');
    peaks = []; locs = []; hr = NaN;
else
    [peaks, locs] = findpeaks(env_smooth, ...
        'MinPeakHeight', 0.3*max(env_smooth), ...
        'MinPeakDistance', 0.3*fs);
end

if numel(locs) > 1
    RR = diff(locs)/fs;
    hr = 60/mean(RR);
else
    hr = NaN;
end

title(sprintf('Spectrogram of Phonocardiogram — Estimated Heart Rate: %.1f bpm', hr));
