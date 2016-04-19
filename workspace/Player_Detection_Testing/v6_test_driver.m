close all; clear all; clc;
Img = imread('Critical_interference_test.png');
Img = Img(:,:,1);
square_center = [round(size(Img, 2)/2), round(size(Img, 1)/2)];
CropImg = Img(square_center(2) - 110 : square_center(2) + 110, square_center(1) - 110 : square_center(1) + 110);
[playerX, playerY] = detect_player_v6(CropImg)