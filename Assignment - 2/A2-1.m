% Step 1: Read the Image
img_rgb = imread('image_16.png');
figure;
imshow(img_rgb);
title('Original Image');

% Step 2: Convert Image to Double Precision
img_rgb = im2double(img_rgb); % Convert to double precision

% Step 3: Separate the RGB Channels
red_channel = img_rgb(:, :, 1);
green_channel = img_rgb(:, :, 2);
blue_channel = img_rgb(:, :, 3);


% Step 6: Denoise Each Channel and apply Linear Filter
Filtered_red = Filtered_channel(red_channel);
Filtered_green = Filtered_channel(green_channel);
Filtered_blue = Filtered_channel(blue_channel);


% Step 7: Combine the Denoised Channels Back to RGB
Final_img_rgb = cat(3, Filtered_red, Filtered_green, Filtered_blue);
figure;
imshow(Final_img_rgb, []);
title('Image after Linear filter');

% Step 8: Apply Median Filter to Each Channel
Final_img_median = zeros(size(Final_img_rgb));

% Apply Median Filter to each channel separately
for i = 1:3
    Final_img_median(:, :, i) = medfilt2(Final_img_rgb(:, :, i), [8 8]); % 8x8 window for better smopothing
end

% Step 9: Display the Final Image after Median Filter
figure;
imshow(Final_img_median, []);
title('Final Image after Median Filter');


% Function to Denoise a Single Channel
function Filtered_channel = Filtered_channel(channel)
    % Perform Fourier Transform
    F = fft2(double(channel)); % Fourier Transform
    Fshift = fftshift(F); % Shift zero-frequency component to center
    magnitude = log(1 + abs(Fshift)); % Compute magnitude spectrum for visualization

    % Step 4: Visualize Magnitude Spectrum in Frequency Domain
    figure;
    imshow(magnitude, []);
    title('Magnitude Spectrum (Frequency Domain)');
    
    
    % Create a Line Filter
    [rows, cols] = size(Fshift);
    centerX = cols / 2;
    centerY = rows / 2;
    lineWidth = 20; % Adjusted width for better coverage
    
    % Initialize the filter as ones
    lineFilter = ones(rows, cols);

    % Suppress vertical line
    lineFilter(:, centerX - lineWidth:centerX + lineWidth) = 0; % Vertical line
    lineFilter(centerY - 10:centerY + 10, :) = 1; % Allow near center

    % Suppress horizontal line
    lineFilter(centerY - lineWidth:centerY + lineWidth, :) = 0; % Horizontal line
    lineFilter(:, centerX - 10:centerX + 10) = 1; % Allow near center

    % Apply the Line Filter
    Fshift_filtered = Fshift .* lineFilter;
    % Visualize the Filtered FFT
    filtered_magnitude = log(1 + abs(Fshift_filtered));
    % Visualize Filtered Magnitude Spectrum in Frequency Domain
    figure;
    imshow(filtered_magnitude, []);
    title('Filtered Magnitude Spectrum');   

    % Apply Inverse Fourier Transform
    F_ishift = ifftshift(Fshift_filtered); % Inverse shift
    Filtered_channel = real(ifft2(F_ishift)); % Inverse Fourier Transform
    
    % Normalize and Enhance Contrast
    Filtered_channel = mat2gray(Filtered_channel); % Normalize
    Filtered_channel = imadjust(Filtered_channel); % Adjust contrast
end

