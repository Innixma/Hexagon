
function [playerX, playerY] = detect_player_v5(Img)
% THIS MUST TAKE IN A CROPPED IMAGE CENTERED AT THE PLAYER'S ORBITAL CENTER
% Version 5 is Version 4 made dimensionless.  The only concern I have is
% with the detection range

tic
Img = Img(:,:,1);

xmax = size(Img, 2);

ymax = size(Img, 1);
square_center = [round(xmax/2), round(ymax/2)];


searchoffset = round(0.9 * square_center(1));
xtop = (square_center(1) - searchoffset); xbottom = (square_center(1) + searchoffset);
ytop = (square_center(2) - searchoffset); ybottom = (square_center(2) + searchoffset);


halfrange = round(0.1 * searchoffset); % half the side of the square patch we search


cx = [round(xtop:xbottom)];
cytop = round(square_center(2) - sqrt(searchoffset^2 - (cx - square_center(1)).^2));
cybottom = round(square_center(2) + sqrt(searchoffset^2 - (cx - square_center(1)).^2));

cx = [cx(1) cx cx];   % the cx(1), cybottom(end) closes a gap through which the player could slip undetected more efficiently than decreasing the stepsize would
cy = [cybottom(end) cytop cybottom];



counter = zeros(size(cx));
algpreptime = toc
% search circle
tic
for h = 1:length(cx)
       
    subImgXinds = [cx(h) - halfrange: cx(h) + halfrange];
    subImgYinds = [cy(h) - halfrange : cy(h) + halfrange];
    
    subImg = Img(subImgYinds, subImgXinds);
    
    
    counter(h) = sum(sum(subImg));
    
end
playercenterind = round(mean(find(counter <=73000 & counter >= 72000)))

playerX = cx(playercenterind);
playerY = cy(playercenterind);
playerfind = toc


debug = 1;

% Diagnostics
imshow(Img)
hold on
plot(size(Img, 2)/2, size(Img, 1)/2, 'g+', 'markersize', 30)
plot(square_center(1), square_center(2), 'rX', 'markersize', 30)
legend('g+ = screenshot center', 'rX = rotation center')
plot(cx, cy, '-gx')
plot(cx(playercenterind), cy(playercenterind), 'rs', 'markersize', 30)
plot(cx(playercenterind), cy(playercenterind), 'r+', 'markersize', 25)
debug = 2;

end


