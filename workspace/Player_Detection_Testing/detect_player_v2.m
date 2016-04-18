close all; clear; clc;
tic
% This version searches a circle rather than a square, and tightens the pixel number range.
% Img = imread('Base_clear.png');
% Img = imread('Base_Close_interference_1.png');
Img = imread('Critical_interference_test.png');
% Img = imread('left.png');
% Img = imread('640 by 480.png');
Img = Img(:,:,1);
imshow(Img)
hold on
plot(size(Img, 2)/2, size(Img, 1)/2, 'g+', 'markersize', 30)
square_center = [round((896+785)/2), round((480+592)/2)];
plot(square_center(1), square_center(2), 'rX', 'markersize', 30)
legend('g+ = screenshot center', 'rX = rotation center')

xtop = (square_center(1) - 100); xbottom = (square_center(1) + 100);
ytop = (square_center(2) - 100); ybottom = (square_center(2) + 100);
% boundsX = [xtop , xbottom, xbottom, xtop, xtop];
% boundsY = [ytop , ytop, ybottom, ybottom, ytop];

% % % % xtop = round(square_center(1) - 100); xbottom = round(square_center(1) + 100);
% % % % ytop = round(square_center(2) - 100); ybottom = round(square_center(2) + 100);
% % % % boundsX = [xtop : xbottom, xbottom*ones(1, 200), xbottom:-1:xtop, xtop*ones(1, 200)];
% % % % boundsY = [ytop * ones(1, 200), ytop:ybottom, ybottom*ones(1, 200), ybottom:-1:ytop];



halfrange = 10; % half the side of the square patch we search

% plot(boundsX, boundsY, '-b.')

cx = [round(xtop:xbottom)];
cytop = round(square_center(2) - sqrt(100^2 - (cx - square_center(1)).^2));
cybottom = round(square_center(2) + sqrt(100^2 - (cx - square_center(1)).^2));

cx = [cx(1) cx cx];   % the cx(1), cybottom(end) closes a gap through which the player could slip undetected more efficiently than decreasing the stepsize would
cy = [cybottom(end) cytop cybottom];

plot(cx, cy, '-gx')

toc
debug = 1;
modImg = Img;
counter = zeros(size(cx));
% search circle
tic
for h = 1:length(cx)
    %     for i = cx(h) - halfrange: cx(h) + halfrange
    %         for j = cy(h) - halfrange : cy(h) + halfrange
    
    subImgXinds = [cx(h) - halfrange: cx(h) + halfrange];
    subImgYinds = [cy(h) - halfrange : cy(h) + halfrange];
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
playercenterind = round(mean(find(counter <=73000 & counter >= 72000)));
playerfind = toc
% figure; imshow(modImg)





plot(cx(playercenterind), cy(playercenterind), 'rs', 'markersize', 30)
plot(cx(playercenterind), cy(playercenterind), 'r+', 'markersize', 25)


% hminIndex = round(mean(

% note: 0 = black, 255 = white.  therefore we are looking or a dip in the
% counter count







debug = 1;
tic;
for h = 1:length(cx)
    for i = cx(h) - halfrange: cx(h) + halfrange
        for j = cy(h) - halfrange : cy(h) + halfrange
            plot(i, j, 'r')
        end
    end
end
plotloop = toc
debug = 1;
% cx = [(square_center(1) - 100) , (square_center(1) + 100), (square_center(1) + 100), (square_center(1) - 100), (square_center(1) - 100) ];
% cy = [(square_center(2) - 100) , (square_center(2) - 100), (square_center(2) + 100), (square_center(2) + 100), (square_center(2) - 100)  ];
