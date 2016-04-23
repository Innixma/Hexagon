%close all; clear; clc;

centerX = round(size(CropImg, 2)/2);
centerY = round(size(CropImg, 1)/2);

%figure; imshow(CropImg); hold on; plot(centerX, centerY, 'rX', 'markersize', 30);

xstart = centerX;
ystart = centerY;

%radius = 50:100;
%lineIntVal = zeros(size(radius));
%xtemp = lineIntVal; 
%ytemp = xtemp;
%theta = 1:360;
dists = zeros(1,360);
%toc
%tic
for i = 1:360
    
    for j = 50:100
        
        xtemp = centerX + j*cosd(i);
        ytemp = centerY + j*sind(i);
        
        lineIntVal = CropImg(floor(ytemp), floor(xtemp));
        if lineIntVal == 0 % Found wall
            %wallvals = j;
            break;
        end
        
    end
    
    %wallvals = find(lineIntVal == 0);
    %firstwallind = wallvals;
    

    %centerWallX = xtemp(firstwallind);
    %centerWallY = ytemp(firstwallind);
    %plot(xtemp, ytemp, 'r.', 'markersize', 30);
    
    dists(i) = j;
end
%toc
%figure; plot(dists)
%tic
[pks,locs] = findpeaks(dists);
%toc    
numvertices = length(locs);
% [H, THETA, RHO] = hough(CropImg); % rho = x*cos(theta) + y*sin(theta)



