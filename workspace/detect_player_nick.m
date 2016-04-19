
function [playerX, playerY] = detect_player_nick(Img)
% Now with an ellipse to deal with stretched images instead of a circle
% THIS MUST TAKE IN A CROPPED IMAGE CENTERED AT THE PLAYER'S ORBITAL CENTER
% Version 5 is Version 4 made dimensionless.  The only concern I have is
% with the detection range

ratio1 = 0.82;
ratio2 = 0.09;

tic
xmax = size(Img, 2);
ymax = size(Img, 1);
square_center = [round(xmax/2), round(ymax/2)];


Xsearchoffset = round(ratio1 * square_center(2));
Ysearchoffset = round(ratio1 * square_center(1));
xtop = (square_center(1) - Xsearchoffset); xbottom = (square_center(1) + Xsearchoffset);
ytop = (square_center(2) - Ysearchoffset); ybottom = (square_center(2) + Ysearchoffset);


Xhalfrange = round(ratio2 * Xsearchoffset); % half the Xside of the square patch we search
Yhalfrange = round(ratio2 * Ysearchoffset); % half the Yside of the square patch we search

pixelGroupSize = (Xhalfrange*2+1) * (Yhalfrange*2+1);

cx = [round(xtop:xbottom)];
cytop = round(square_center(2) - sqrt(Ysearchoffset^2 - (cx - square_center(1)).^2));
cybottom = round(square_center(2) + sqrt(Ysearchoffset^2 - (cx - square_center(1)).^2));

cx = [cx(1) cx cx];   % the cx(1), cybottom(end) closes a gap through which the player could slip undetected more efficiently than decreasing the stepsize would
cy = [cybottom(end) cytop cybottom];

%{
imshow(Img)
hold on
plot(size(Img, 2)/2, size(Img, 1)/2, 'g+', 'markersize', 30)
plot(square_center(1), square_center(2), 'rX', 'markersize', 30)
legend('g+ = screenshot center', 'rX = rotation center')
plot(cx, cy, '-gx')
%}

counter = zeros(size(cx));
algpreptime = toc
% search circle
tic
for h = 1:length(cx)
       
    subImgXinds = [cx(h) - Xhalfrange: cx(h) + Xhalfrange];
    subImgYinds = [cy(h) - Yhalfrange : cy(h) + Yhalfrange];
    
    subImg = Img(subImgYinds, subImgXinds);
    
    
    counter(h) = sum(sum(subImg))/pixelGroupSize;
    
end
%disp(find(counter <=0.605 & counter >= 0.596));

playercenterind = round(mean(find(counter <=0.605 & counter >= 0.596)));

playerX = cx(playercenterind);
playerY = cy(playercenterind);
playerfind = toc


%debug = 1;

% Diagnostics

%{
plot(cx(playercenterind), cy(playercenterind), 'rs', 'markersize', 30)
plot(cx(playercenterind), cy(playercenterind), 'r+', 'markersize', 25)
%}

%debug = 2;

end


