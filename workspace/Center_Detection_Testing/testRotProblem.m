close all; clear; clc;
rotImg = imread('rotationProblem.png');
rotImg = rotImg(:,:,1);
%imshow(rotImg); hold on;
square_center = [963.5000  413.0000];
%plot(square_center(1), square_center(2), 'rX', 'markersize', 30);
CropImg = rotImg(square_center(2) - 300 : square_center(2) + 300, square_center(1) - 300 : square_center(1) + 300);
%figure; imshow(CropImg);
tic
[centerSize, numSides, wallAngles] = real_centerbox_final_nick(CropImg);
toc
%{
tic
[centerSize, numSides, wallAngles] = centerboxFinal(CropImg);
toc
%}