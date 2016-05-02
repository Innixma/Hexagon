function [centerSize, numSides, wallAngles] = real_centerbox_final_nick(CropImg)
    % Main code by Danesh, 
    % Heavily modified and optimized by Nick
    % Major rotation bug fixed by Danesh

    centerX = round(size(CropImg, 2)/2);
    centerY = round(size(CropImg, 1)/2);

    %figure; imshow(CropImg); hold on; plot(centerX, centerY, 'rX', 'markersize', 30);

    radius = 30:70;
    lineIntVal = zeros(size(radius));
    thetas = 1:360;
    dists = zeros(size(thetas));

    for i = 1:length(thetas)

        for j = 1:length(radius)        
            lineIntVal(j) = CropImg(floor(centerY + radius(j)*sind(thetas(i))), floor(centerX + radius(j)*cosd(thetas(i))));
            if lineIntVal(j) == 0
                break;
            end
        end

         %plot(centerWallX, centerWallY, 'r.', 'markersize', 30);

        dists(i) = radius(j);
    end

    %figure; plot(dists);
    

% Promising solution:

highlighting_shift = 5;  % Padding dists with zeros improves findpeaks' ability to find peaks ( it boosts the prominences).  My choice of 5 as the pad was arbitrary, but it seems to work fine.
augmented_dists = [zeros(1, highlighting_shift) dists zeros(1, highlighting_shift)];
[apks, alocs, aw, ap] = findpeaks(augmented_dists);
possible_indices = find(apks > max(apks) - 7);
for i = 1:length(possible_indices)-1
    if possible_indices(i+1) == possible_indices(i) + 1
        if ap(possible_indices(i+1)) >= ap(possible_indices(i))  %  If the prominence of the latter is greater than or equal to that of the former, use the latter (it should NEVER be equal)
            best_pks_indices(i) = possible_indices(i+1);
        elseif ap(possible_indices(i)) < ap(possible_indices(i+1))
            best_pks_indices(i) = possible_indices(i);
        end
    elseif possible_indices(i+1) ~= possible_indices(i) + 1
        best_pks_indices(i) = possible_indices(i);
        best_pks_indices(i + 1) = possible_indices(i + 1); % so we don't lose the last element
    end
 
end

%check to make sure the peak indices are not too close to each other, say,
%within 5 of each other ( I only saw one case where they
%were even within 1 of each other but I select the window using the following subroutine for the sake of flexibility.)
 %debug = 2;    
test = unique(best_pks_indices);
for j = 2:length(test)
    testdiffs(j-1) = abs(test(j) - test(j-1));
end
window = ceil(0.5 * median(testdiffs));
 %debug = 2;   
for i = 2:length(best_pks_indices)
    diff = abs(best_pks_indices(i) - best_pks_indices(i-1));
    if ( diff < window && diff > 0)
        % if two peak indices are too close to each other (but not identical), set the one with
        % the lower prominence equal to the one with the higher prominence
        % because I will be able to wipe out duplicates later
        if (ap(best_pks_indices(i-1)) >= ap(best_pks_indices(i)))
            best_pks_indices(i) = best_pks_indices(i-1); 
        elseif ap(best_pks_indices(i-1) < ap(best_pks_indices(i)))
            best_pks_indices(i-1) = best_pks_indices(i);  
        end
    end
end

% Need to check for the end effects!  But how?
% Think about the geometry of the situation.  If it starts at a vertex
% it will end at or just before the vertex, so there will be peaks
% close to the start AND the end of dists...
if ( (alocs(possible_indices (1)) - highlighting_shift ) <= 10 && ( alocs(possible_indices(end)) - highlighting_shift) >= length(dists) - 10)
    %fprintf('there is probably some overlap problem!\n')
    if ap(possible_indices(1)) >= ap(possible_indices(end)) % the 'or =' is an arbitrary choice to bias it toward the first peak.  There is no functional effect of biasing it the other way.
        best_pks_indices(end) = [];  % delete the 'duplicate' vertex which has a lower priority
    elseif ap(possible_indices(end)) > ap(possible_indices(1))
        best_pks_indices(1) = [];
    end
end

best_pks_indices = unique(best_pks_indices);  % make sure there are no duplicates
best_dist_indices = alocs(best_pks_indices) - highlighting_shift;
%figure; plot(dists, '-bO'); hold on; plot(best_dist_indices, dists(best_dist_indices), 'rX', 'markersize', 30); 
%title('distances'); xlabel('index'); ylabel('magnitude'); legend('bO: distances', 'rX: peak distances (vertices)');




wallAngles = thetas(best_dist_indices);
numSides = length(best_dist_indices);
centerSize = mean(dists);


end
