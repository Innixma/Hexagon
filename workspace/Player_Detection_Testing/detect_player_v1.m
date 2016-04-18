close all; clear; clc;
tic
% Img = imread('Base_clear.png');
% Img = imread('Base_middle.png');
Img = imread('Base_Close_interference_1.png');
Img = Img(:,:,1);
imshow(Img)
hold on
plot(size(Img, 2)/2, size(Img, 1)/2, 'g+', 'markersize', 30)
square_center = [(896+785)/2, (480+592)/2];
plot(square_center(1), square_center(2), 'rX', 'markersize', 30)
legend('g+ = screenshot center', 'rX = rotation center')

% xtop = (square_center(1) - 100); xbottom = (square_center(1) + 100);
% ytop = (square_center(2) - 100); ybottom = (square_center(2) + 100);
% boundsX = [xtop , xbottom, xbottom, xtop, xtop];
% boundsY = [ytop , ytop, ybottom, ybottom, ytop];

xtop = round(square_center(1) - 100); xbottom = round(square_center(1) + 100);
ytop = round(square_center(2) - 100); ybottom = round(square_center(2) + 100);
boundsX = [xtop : xbottom, xbottom*ones(1, 200), xbottom:-1:xtop, xtop*ones(1, 200)];
boundsY = [ytop * ones(1, 200), ytop:ybottom, ybottom*ones(1, 200), ybottom:-1:ytop];

halfrange = 10;

% plot(boundsX, boundsY, '-b.')
toc

modImg = Img;
counter = zeros(size(boundsX));
%searchsquare
tic
for h = 1:length(boundsX)
%     for i = boundsX(h) - halfrange: boundsX(h) + halfrange
%         for j = boundsY(h) - halfrange : boundsY(h) + halfrange  
            
            subImgXinds = [boundsX(h) - halfrange: boundsX(h) + halfrange];
            subImgYinds = [boundsY(h) - halfrange : boundsY(h) + halfrange];
%             subImg = Img(subImgXinds, subImgYinds);
            subImg = Img(subImgYinds, subImgXinds);
            
%             
%             if h > 290 && h < 400
%                 debug = 1;
%                 counter(h) = sum(sum(subImg));
%             end
%             modImg(subImgXinds, subImgYinds) = 0;
            modImg(subImgYinds, subImgXinds) = 0;
            counter(h) = sum(sum(subImg));
%             debug = 2;

%         end
%     end
end
sumloop = toc
% figure; imshow(modImg)



playercenterind = round(mean(find(counter <=73000 & counter >= 72000)));
plot(boundsX(playercenterind), boundsY(playercenterind), 'rs', 'markersize', 30)
plot(boundsX(playercenterind), boundsY(playercenterind), 'r+', 'markersize', 25)

debug = 3;
% hminIndex = round(mean( 

% note: 0 = black, 255 = white.  therefore we are looking or a dip in the
% counter count








tic;
for h = 1:length(boundsX)
    for i = boundsX(h) - halfrange: boundsX(h) + halfrange
        for j = boundsY(h) - halfrange : boundsY(h) + halfrange
            plot(i, j, 'r')
        end
    end
end
plotloop = toc
debug = 1;
% boundsX = [(square_center(1) - 100) , (square_center(1) + 100), (square_center(1) + 100), (square_center(1) - 100), (square_center(1) - 100) ];
% boundsY = [(square_center(2) - 100) , (square_center(2) - 100), (square_center(2) + 100), (square_center(2) + 100), (square_center(2) - 100)  ];
