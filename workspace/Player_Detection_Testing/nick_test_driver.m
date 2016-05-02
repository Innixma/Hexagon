close all; clear all; clc;
Img = imread('Critical_interference_test.png');
Img = Img(:,:,1);
Img = im2bw(Img, 0.8);
square_center = [round(size(Img, 2)/2), round(size(Img, 1)/2)];
CropImg = Img(square_center(2) - 130 : square_center(2) + 130, square_center(1) - 130 : square_center(1) + 130);
[playerX, playerY] = detect_player_nick(CropImg);