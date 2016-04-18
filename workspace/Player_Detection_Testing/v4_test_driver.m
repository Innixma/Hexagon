Img = imread('Critical_interference_test.png');
Img = Img(:,:,1);
CropImg = Img(square_center(2) - 110 : square_center(2) + 110, square_center(1) - 110 : square_center(1) + 110);
[playerX, playerY] = detect_player_v4(CropImg)