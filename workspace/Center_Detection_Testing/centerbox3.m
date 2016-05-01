%close all; clear; clc;
%Img = double(imread('Critical_interference_test.png'));
%Img = Img(:,:,1);
%Img = im2bw(Img, 0.5);
%square_center = [round((896+785)/2), round((480+592)/2)];
%CropImg = Img(square_center(2) - 110 : square_center(2) + 110, square_center(1) - 110 : square_center(1) + 110);

centerX = round(size(CropImg, 2)/2);
centerY = round(size(CropImg, 1)/2);

%figure; imshow(CropImg); hold on; plot(centerX, centerY, 'rX', 'markersize', 30);

radius = 50:100;
lineIntVal = zeros(size(radius));
xtemp = lineIntVal; 
ytemp = xtemp;
theta = 1:360;
dists = zeros(size(theta));

for i = 1:length(theta)
    
    for j = 1:length(radius)
        
        xtemp(j) = centerX + radius(j)*cosd(theta(i));
        ytemp(j) = centerY + radius(j)*sind(theta(i));
        
        lineIntVal(j) = CropImg(floor(ytemp(j)), floor(xtemp(j)));
        if lineIntVal(j) == 0
            break;
        end
    end
    
    %wallvals = find(lineIntVal == 0);
    %firstwallind = wallvals(1);
    %firstwallind = j;

    %centerWallX = xtemp(firstwallind);
    %centerWallY = ytemp(firstwallind);
    %plot(centerWallX, centerWallY, 'r.', 'markersize', 30);
    
    dists(i) = j;
end

%figure; plot(dists)

[pks,locs] = findpeaks(dists);
        
numvertices = length(locs);
% [H, THETA, RHO] = hough(CropImg); % rho = x*cos(theta) + y*sin(theta)


