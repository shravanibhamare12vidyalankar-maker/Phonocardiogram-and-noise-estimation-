% Noise Estimation (Eq. 7) from HH subband

clear; close all;

% Load grayscale image
I = im2double(imread('cameraman.tif'));

% Add Gaussian noise (σ = 20/255 ~ 0.078)
sigma_true = 0.08;
I_noisy = I + sigma_true*randn(size(I));

% 1-level wavelet decomposition using LeGall (bior2.2)
[LL, LH, HL, HH] = dwt2(I_noisy, 'bior2.2');

% Eq. (7) noise estimation
sigma_hat = median(abs(HH(:))) / 0.6745;

fprintf('True sigma = %.4f\n', sigma_true);
fprintf('Estimated sigma (Eq.7) = %.4f\n', sigma_hat);

% Display
subplot(1,3,1), imshow(I), title('Original');
subplot(1,3,2), imshow(I_noisy), title('Noisy');
subplot(1,3,3), imshow(HH,[]), title('HH subband');