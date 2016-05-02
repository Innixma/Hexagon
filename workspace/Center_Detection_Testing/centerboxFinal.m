function [centerSize, numSides, wallAngles] = centerboxFinal(CropImg)
    % Main code by Danesh, 
    % Heavily modified and optimized by Nick

    centerX = round(size(CropImg, 2)/2);
    centerY = round(size(CropImg, 1)/2);

    figure; imshow(CropImg); hold on; plot(centerX, centerY, 'rX', 'markersize', 30);

    radius = 100:250;
    lineIntVal = zeros(size(radius));
    theta = 1:360;
    dists = zeros(size(theta));

    for i = 1:length(theta)

        for j = 1:length(radius)        
            lineIntVal(j) = CropImg(floor(centerY + radius(j)*sind(theta(i))), floor(centerX + radius(j)*cosd(theta(i))));
            if lineIntVal(j) == 0
                break;
            end
        end

%         plot(centerWallX, centerWallY, 'r.', 'markersize', 30);

        dists(i) = radius(j);
    end

    figure; plot(dists)

    [pks,wallAngles] = findpeaks(dists);

    % [H, THETA, RHO] = hough(CropImg); % rho = x*cos(theta) + y*sin(theta)

    numSides = length(wallAngles);
    centerSize = max(pks);
    
end
