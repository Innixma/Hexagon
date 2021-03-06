%close all; clear; clc;
%Img = double(imread('Critical_interference_test.png'));
%Img = Img(:,:,1);
%Img = im2bw(Img, 0.5);
%square_center = [round((896+785)/2), round((480+592)/2)];
%CropImg = Img(square_center(2) - 110 : square_center(2) + 110, square_center(1) - 110 : square_center(1) + 110);

centerX = round(size(CropImg, 2)/2);
centerY = round(size(CropImg, 1)/2);

%figure; imshow(CropImg); hold on; plot(centerX, centerY, 'rX', 'markersize', 30);

radius = 51:100;
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
    
    %plot(centerWallX, centerWallY, 'r.', 'markersize', 30);
    
    dists(i) = radius(j);
end

%figure; plot(dists)

[pks,locs] = findpeaks(dists);
        
numvertices = length(locs);
% [H, THETA, RHO] = hough(CropImg); % rho = x*cos(theta) + y*sin(theta)


