% By Nick Erickson
% Basic Edge Detection
I = imread('original.jpg');
imshow(I)
grayImage = rgb2gray(I);
imshow(grayImage)
BW1 = edge(grayImage,'sobel');
BW2 = edge(grayImage,'canny');
figure;
imshowpair(BW1,BW2,'montage')
title('Sobel Filter                                   Canny Filter');