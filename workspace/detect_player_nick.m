function [playerX, playerY] = detect_player_nick(Img, centerSize, playerSize)
% Now with an ellipse to deal with stretched images instead of a circle
% THIS MUST TAKE IN A CROPPED IMAGE CENTERED AT THE PLAYER'S ORBITAL CENTER
% Version 5 is Version 4 made dimensionless.  The only concern I have is
% with the detection range

% Original by Danesh
% Heavily modified by Nick
%tic

% Player = 78 pixels on 764x1020 (Approx 9x9)

xmax = size(Img, 2);
ymax = size(Img, 1);

ratioNew = round(centerSize*1.35);

% area ratio to look around the detection ellipse
ratioArea = round(sqrt(playerSize)*1.2);

%ratio1 = 0.83;
%ratio2 = 0.16;

%upperThreshold = 0.625;
%lowerThreshold = 0.546;
%upperThreshold = 0.90;
%lowerThreshold = 0.855;
%lowerThreshold = 0.865;

%tic

square_center = [round(xmax/2), round(ymax/2)];



%Xsearchoffset = round(ratio1 * square_center(1));
%Ysearchoffset = round(ratio1 * square_center(2));

% pixel offset to look around the detection ellipse
Xsearchoffset = ratioNew;
Ysearchoffset = ratioNew*ymax/xmax;

if Xsearchoffset+ratioArea >= xmax/2 || Ysearchoffset+ratioArea >= ymax/2
    playerX = -1;
    playerY = -1;
    return;
end

xtop = (square_center(1) - Xsearchoffset); xbottom = (square_center(1) + Xsearchoffset);
ytop = (square_center(2) - Ysearchoffset); ybottom = (square_center(2) + Ysearchoffset);

%Xhalfrange = round(ratio2 * Xsearchoffset); % half the Xside of the square patch we search
%Yhalfrange = round(ratio2 * Ysearchoffset); % half the Yside of the square patch we search

Xhalfrange = ratioArea;
Yhalfrange = ratioArea;

pixelGroupSize = (Xhalfrange*2+1) * (Yhalfrange*2+1);

playerThreshold = 1 - playerSize/pixelGroupSize;
upperThreshold = playerThreshold+0.04;
lowerThreshold = playerThreshold-0.002;




a = (xbottom-xtop)/2;
b = (ybottom-ytop)/2;

%% find bin x/y values for pixels around the detection ellipse
% Theta from 0 to 359
cx = zeros(1,180);
cy = zeros(1,180);
for j = 0:179
    i = j*2;
    radians = i/180*pi;
    if i < 90
        cx(j+1) = sqrt(a^2 * cos(radians)^2) + square_center(1);
        cy(j+1) = sqrt(b^2 * sin(radians)^2) + square_center(2);
    elseif i < 180
        cx(j+1) = -sqrt(a^2 * cos(radians)^2) + square_center(1);
        cy(j+1) = sqrt(b^2 * sin(radians)^2) + square_center(2);
    elseif i < 270
        cx(j+1) = -sqrt(a^2 * cos(radians)^2) + square_center(1);
        cy(j+1) = -sqrt(b^2 * sin(radians)^2) + square_center(2);
    else
        cx(j+1) = sqrt(a^2 * cos(radians)^2) + square_center(1);
        cy(j+1) = -sqrt(b^2 * sin(radians)^2) + square_center(2);
    end
end

cx = round(cx);
cy = round(cy);

%% find bin counts for pixels around the detection ellipse
counter = zeros(size(cx));
%algpreptime = toc
% search circle
%tic
for h = 1:length(cx)
       
    subImgXinds = cx(h) - Xhalfrange: cx(h) + Xhalfrange;
    subImgYinds = cy(h) - Yhalfrange: cy(h) + Yhalfrange;
    
    subImg = Img(subImgYinds, subImgXinds);
    
    
    counter(h) = sum(sum(subImg))/pixelGroupSize;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New stuff, derivative (V0.10)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%disp(find(counter <= upperThreshold & counter >= lowerThreshold));

candidates = find(counter <= upperThreshold & counter >= lowerThreshold);

if isempty(candidates)
   playerX = -1;
   playerY = -1;
   return
end

cLen = size(candidates, 2);

if cLen > 1 % Find longest run
    temp2 = zeros(1,cLen-1);
    temp2(1:cLen-1) = candidates(2:cLen) - candidates(1:cLen-1);

    runSize = 1;
    runScore = 0;
    runSizeMax = 0;
    runScoreMax = 0;
    runSizeFirst = 1;
    runIndex = 1;
    
    % For first one
    runScore = runScore + 1/(0.2+abs(playerThreshold-counter(candidates(1)))/(upperThreshold-lowerThreshold));
    for i = 1:cLen-1
        if temp2(i) == 1
            runSize = runSize + 1;
            runScore = runScore + 1/(0.2+abs(playerThreshold-counter(candidates(i+1)))/(upperThreshold-lowerThreshold));
            if i == cLen-1
                if runScoreMax < runScore
                    runSizeMax = runSize;
                    runScoreMax = runScore;
                    runIndexMax = runIndex;
                end
            end
        else
            if runScoreMax < runScore
                runSizeMax = runSize;
                runScoreMax = runScore;
                runIndexMax = runIndex;
                if runIndex == 1
                    runSizeFirst = runSize;
                    runScoreFirst = runScore;
                end
            end
            runSize = 1;
            runScore = 1/(0.2+abs(playerThreshold-counter(candidates(i+1)))/(upperThreshold-lowerThreshold));
            runIndex = i;
        end
    end
                       
    if candidates(1) == 1 && candidates(cLen) == j+1
       % LOOP!
       loop = true;
       runSize = runSize + runSizeFirst;
       runScore = runScore + runScoreFirst;
       runIndex = 1;
       if runScoreMax < runScore
            runSizeMax = runSize;
            %runScoreMax = runScore;
            runIndexMax = runIndex;
       end
       
    else
        loop = false;
       
    end
    
    % Not perfect for looping
    if loop == true
        candID = runIndexMax;
    else
        candID = runIndexMax + floor(runSizeMax/2);
    end
    playercenterind = candidates(candID);
    
else
   playercenterind = candidates(1); 
end

%playercenterind = round(mean(find(counter <= upperThreshold & counter >= lowerThreshold)));

playerX = cx(playercenterind);
playerY = cy(playercenterind);
%playerfind = toc


%debug = 1;

% Diagnostics

%imshow(Img)
%hold on
%plot(square_center(1), square_center(2), 'rX', 'markersize', 30)
%plot(cx, cy, '-gx')

%plot(cx(playercenterind), cy(playercenterind), 'rs', 'markersize', 30)
%plot(cx(playercenterind), cy(playercenterind), 'r+', 'markersize', 25)


%debug = 2;
%toc
end


