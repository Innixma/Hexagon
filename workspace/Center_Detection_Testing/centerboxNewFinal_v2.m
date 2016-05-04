function [centerSize, numSides, wallAngles] = centerboxNewFinal_v2(CropImg)
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

    figure; plot(dists);
    
    % Need to do the following to accurately process.  I can find the
    % number of sides but not the locations yet.
    
% % %     doubledists = [zeros(1, 5) dists dists zeros(1, 5)];
% % %     [pks, locs, w, p] = findpeaks(dists);
% % %     [doublepks,doublelocs, doublew, doublep] = findpeaks(doubledists);
% % %     doublepeaks = find(doublep > 1.25 * mean(doublep))
% % %     numsides = floor(length(doublepeaks)/2)
% % %     debug = 1;
  
%% Promising solution:

highlighting_shift = 5;  % Padding dists with zeros improves findpeaks' ability to find peaks ( it boosts the prominences)
augmented_dists = [zeros(1, highlighting_shift) dists zeros(1, highlighting_shift)];
[apks, alocs, aw, ap] = findpeaks(augmented_dists);
possible_indices = find(apks > max(apks) - 30)
for i = 1:length(possible_indices)-1
    if possible_indices(i+1) == possible_indices(i) + 1
        if ap(i+1) >= ap(i)  %  If the prominence of the latter is greater than or equal to that of the former, use the latter (it should NEVER be equal)
            best_pks_indices(i) =possible_indices(i+1);
        elseif ap(i) < ap(i+1)
            best_pks_indices(i) = possible_indices(i);
        end
    elseif possible_indices(i+1) ~= possible_indices(i) + 1
        best_pks_indices(i) = possible_indices(i);
        best_pks_indices(i + 1) = possible_indices(i + 1); % so we don't lose the last element
    end
  
end
% Need to check for the end effects!  But how?
% Think about the geometry of the situation.  If it starts at a vertex
% it will end at or just before the vertex, so there will be peaks
% close to the start AND the end of dists...
if ( (alocs(possible_indices (1)) - highlighting_shift ) <= 10 && ( alocs(possible_indices(end)) - highlighting_shift) >= length(dists) - 10)
    fprintf('there is probably some overlap problem!\n')
    if ap(possible_indices(1)) >= ap(possible_indices(end)) % the 'or =' is an arbitrary choice to bias it toward the first peak.  There is no functional effect of biasing it the other way.
        best_pks_indices(end) = [];  % delete the 'duplicate' vertex which has a lower priority
    elseif ap(possible_indices(end)) > ap(possible_indices(1))
        best_pks_indices(1) = [];
    end
end

best_pks_indices = unique(best_pks_indices);
best_dist_indices = alocs(best_pks_indices) - highlighting_shift;
figure; plot(dists, '-bO'); hold on; plot(best_dist_indices, dists(best_dist_indices), 'rX', 'markersize', 30)
debug = 1

    
    %     [pks, wallAngles] = findpeaks(pks) % Again
% % % % %     wallAngles = locs;
% % % % %     numSides = length(pks) 
% % % % %     centerSize = max(pks);
    debug = 1;

%     [H, THETA, RHO] = hough(CropImg); % rho = x*cos(theta) + y*sin(theta)
    
    %% negate, thin, and hough fit
    
%     negImg = CropImg;
%     negImg( negImg == 0) = 254;
%     max(max(negImg))
%     negImg(negImg == 255) = 0;
%     negImg(negImg == 254) = 255;
%     imshow(negImg);
%     NBW = negImg;
%     NBW = bwmorph(negImg, 'thin', 'inf');
%     imshow(NBW)
%     [H, T, R] = hough(NBW);  % http://www.mathworks.com/help/images/ref/houghlines.html#buwgo_f-2_1
%     P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
%     numSides = length(P)
%     centerSize = max(pks);


% %     x = T(P(:,2)); y = R(P(:,1));

% %     numSides = length(wallAngles);   % this isn't working

    
end
