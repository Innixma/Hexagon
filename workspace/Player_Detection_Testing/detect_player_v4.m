function [playerX, playerY] = detect_player_v4(Img)

Img = Img(:,:,1);
imloadtime = toc

tic
square_center = [(896+785)/2, (480+592)/2];  % hardcoded for now, but Nick said he had the center problem worked out so I can change that on his system

xtop = (square_center(1) - 100); xbottom = (square_center(1) + 100);
ytop = (square_center(2) - 100); ybottom = (square_center(2) + 100);


halfrange = 10; % half the side of the square patch we search


cx = [round(xtop:xbottom)];
cytop = round(square_center(2) - sqrt(100^2 - (cx - square_center(1)).^2));
cybottom = round(square_center(2) + sqrt(100^2 - (cx - square_center(1)).^2));

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




end


