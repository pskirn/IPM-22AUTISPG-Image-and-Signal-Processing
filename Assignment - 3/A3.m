% Hough Transform: Detect Lines at All Angles

% 1. Load and Process the Image
imagePath = '1.png'; % Replace with your image path
I = imread(imagePath);

%Display the Image
figure;
imshow(I);
title('Input Image');


% Convert to grayscale if needed
if size(I, 3) == 3
    I = rgb2gray(I);
end

% 2. Edge Detection
edges = edge(I, 'Canny'); % Detect edges using Canny method
figure; imshow(edges); title('Detected Edges');

% 3. Hough Transform Parameters
[height, width] = size(edges);
rhoLimit = ceil(sqrt(height^2 + width^2)); % Maximum rho
rho = -rhoLimit:1:rhoLimit;                % Range of rho values
theta = -90:1:90;                          % Range of theta values (1° resolution)
thetaRad = deg2rad(theta);                 % Convert theta to radians

% Initialize Hough Accumulator
houghSpace = zeros(length(rho), length(theta));

% Find Edge Pixels
[yEdges, xEdges] = find(edges); % Edge coordinates

% 4. Accumulate Votes in Hough Space
for idx = 1:length(xEdges)
    x = xEdges(idx);
    y = yEdges(idx);
    for tIdx = 1:length(thetaRad)
        r = round(x * cos(thetaRad(tIdx)) + y * sin(thetaRad(tIdx)));
        rhoIdx = r + rhoLimit + 1; % Offset for indexing
        if rhoIdx >= 1 && rhoIdx <= length(rho)
            houghSpace(rhoIdx, tIdx) = houghSpace(rhoIdx, tIdx) + 1;
        end
    end
end

% 5. Display the Hough Transform Space
figure;
imshow(imadjust(rescale(houghSpace)), [], 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit');
xlabel('\theta (degrees)');
ylabel('\rho (pixels)');
title('Hough Transform Space');
axis on, axis normal, hold on;
colormap(gca,hot);

% 6. Detect Peaks in Hough Space
thresholdPercent = 0.3; % Set threshold as percentage of max value
windowSize = 10;         % Neighborhood size for peak detection
halfWindow = floor(windowSize / 2);

threshold = thresholdPercent * max(houghSpace(:)); % Threshold value
peaks = zeros(size(houghSpace)); % Initialize peak map

for i = 1:size(houghSpace, 1)
    for j = 1:size(houghSpace, 2)
        if houghSpace(i, j) >= threshold
            % Define neighborhood around the current point
            rowMin = max(i - halfWindow, 1);
            rowMax = min(i + halfWindow, size(houghSpace, 1));
            colMin = max(j - halfWindow, 1);
            colMax = min(j + halfWindow, size(houghSpace, 2));
            neighborhood = houghSpace(rowMin:rowMax, colMin:colMax);

            % Check if it's the local maximum
            if houghSpace(i, j) == max(neighborhood(:))
                peaks(i, j) = 1; % Mark as a peak
            end
        end
    end
end

% Extract Detected Rho and Theta Values
[peakRows, peakCols] = find(peaks);
detectedLines = [rho(peakRows)', theta(peakCols)'];

% 7. Plot Detected Lines on the Original Image
figure; imshow(I); hold on;

for i = 1:size(detectedLines, 1)
    rhoValue = detectedLines(i, 1);
    thetaValue = deg2rad(detectedLines(i, 2));

    % Line equation: x*cos(theta) + y*sin(theta) = rho
    % To plot, find two points that satisfy this equation
    if sin(thetaValue) ~= 0 % Avoid division by zero
        x1 = 0; % Start at left edge
        y1 = (rhoValue - x1 * cos(thetaValue)) / sin(thetaValue);
        x2 = width; % End at right edge
        y2 = (rhoValue - x2 * cos(thetaValue)) / sin(thetaValue);
    else
        % Vertical line case
        x1 = rhoValue / cos(thetaValue);
        x2 = x1;
        y1 = 0;
        y2 = height;
    end

    % Plot the line
    plot([x1, x2], [y1, y2], 'r', 'LineWidth', 1.5);
end

title('Hough Transform for Image');
hold off;



