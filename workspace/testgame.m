% By Nick Erickson
% Code runs game very basically.
% Hard coded for 1920x1080 screen, will make dynamic in future.
% NOTICE: Game stretches with screen. Can make it a box in future.
% Making it a box will simply the calculations DRASTICALLY!
% We should do this.

% TO RUN:
% 1. Open OpenHexagon, and go to custom level "BASE".
% 2. Alt-Enter to Make sure the game is in WINDOWED MODE
% 3. Maximize Windowed mode, so it is still windowed, but takes up entire
% screen, including top bar with name Open Hexagon 1.92 - by vittorio romeo
% 4. MAKE SURE monitor is 1920x1080, otherwise this will not work.
% 5. THEN, run the Matlab code and click in the game so it is taking priority.
% 6. Script will run itself in game and play the game.

% Required to beat level:
%   Wall Side # + Distance from center
%       Lesser: Wall Velocity
%       Lesser: Wall Width
%   Player Side # + exact angle
%   With this info you can beat level.
%   Can reorganize problem as a line with a teleport from one end to the
%   other that the player can travel on. Walls come down vertically, with
%   number of segments equal to number of sides. MUCH easier at this
%   point. (Removes all noise)

% IMPROVEMENTS:
% Need to remove walls from center for player detection instead of just
% ignorning player detection completely when a wall is present. Too lazy to
% implement it atm.

% CENTER BOX DIMENSIONS = 
% y = 583-586, y = 478-481, x = 883-888, x = 1033-1038
% Top left = (883,478) ---> (x,y)
% Bottom right = (1038, 586): THUS IGNORE THIS AREA.
% 155 by 108 square

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters:
% Window location coords, (1,1) = top left
x_offset = 0;
y_offset = 20;
x_max = 1920;
y_max = 1020;

%[x_offset,y_offset,x_max,y_max] = screenselect();
x_offset = 458;
y_offset = 188;
x_max = 1020;
y_max = 764;


if mod(x_max,2) ~= 0
    x_max = x_max - 1;   
end
if mod(y_max,2) ~= 0
    y_max = y_max - 1;   
end


frames = 600; % How long code runs
video_img = zeros(y_max,x_max,frames);
first_wall_list = zeros(1,frames);
numWalls_list = zeros(1,frames);
centerSize_list = zeros(1,frames);
player_list = zeros(2,frames);
bestMove_list = zeros(1,frames);
playerWall_list = zeros(1,frames);
wallDistance_list = zeros(10,frames);
movingChoice_list = zeros(1,frames);
startingWall_list = zeros(10,2,frames);
framerate = 40; % Approximate amount of frames processed per second
numSides = 4;
image_threshold = 0.2; % From 1 to 0, threshold is more strict with higher number


% Lower value = More picky with its position, more prone to error
centering_threshold = 25; % Angle away from the center of a safe side that the AI is content with being.

% seconds to go 360 degrees:
rotationSpeed = 0.62;

% Lower value = More risky in its movements
player_closeness_threshold = 45;

%center_areafix_x = round(x_max/10)-55; % Change these two variables to accurately include center box and player for player detection
%center_areafix_x = round(x_max/10)-30;
center_areafix_x = round(x_max/10)-14;
center_areafix_y = round(y_max/10)+6;

% These params don't matter for Danesh, make them = 1
center_boxfix_x = round(center_areafix_x/1.25); % Change these two variables to accurately remove center box from player detection
center_boxfix_y = round(center_areafix_y/1.25); % Too large of values will also remove the player, so be careful

wall_start_x = center_boxfix_x + 15; % Increase if wall finder is detecting the player as a wall
wall_start_y = center_boxfix_y + 15;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization Variables
lockFrames = 0;
setLockFrames = 0;
movingLeft = 0;
movingRight = 0;
playerAngle = 0;
playerAnglePrevious = 0;
previousMove = 0;
wallDistancePrevious = zeros(1, numSides);
numSidesPrevious = numSides;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_half = round(x_max/2);
y_half = round(y_max/2);
x_center = x_half;
y_center = y_half;
diag_length = sqrt(x_center^2 + y_center^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
for i = 1:frames
    %tic;
    if mod(i,100) == 0
        timeElapsed = toc;
        framerate = round(100 / timeElapsed);
        disp(['Framerate = ' int2str(framerate)]);
        tic;
    end
    playerWallPosition = 0;
    
    if lockFrames ~= 0
        lockFrames = lockFrames - 1;
    end
    %tic;
    video_img(:,:,i) = screencapture(x_offset, y_offset, x_max, y_max);
    % make it binary
    
    capture_img = im2bw(video_img(:,:,i), image_threshold);
    
    %capture_img = imcomplement(capture_img);
    
    centerImg = capture_img(y_center-center_areafix_y:y_center+center_areafix_y,x_center-center_areafix_x:x_center+center_areafix_x);
    centerImg_size = size(centerImg);
    centerImg_center = floor(centerImg_size/2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Center
    
    %[centerSize, numSides, wallAngles] = centerboxFinal(centerImg);
    [centerSize, numSides, wallAngles] = centerboxNick(centerImg);
    
    
    if numSides < 3
        disp('Waiting for game to start')
        disp(['numSides = ' int2str(numSides)]);
        continue;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VIDEORECORDING
    numWalls_list(i) = numSides;
    first_wall_list(i) = wallAngles(1);
    centerSize_list(i) = centerSize;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    idealAngles = zeros(1,numSides);
    idealAngles(1) = mod(wallAngles(numSides)+wallAngles(1)-360,360);
    if idealAngles(1) > 180
        idealAngles(1) = idealAngles(1)+(360-idealAngles(1))/2;
    else
        idealAngles(1) = idealAngles(1)/2;
    end
    for j = 2:numSides
       idealAngles(j) = (wallAngles(j-1) + wallAngles(j)) / 2; 
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Player
    %tic
    [player_x, player_y] = detect_player_nick(centerImg);
    player_list(:,i) = [player_y,player_x];
    %toc
    if player_x == -1
        playerFound = false;
        disp('Player not found!');
    else
        playerFound = true;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate Player Angle
    if playerFound == true
        yRel = -(-centerImg_center(1)+player_y);
        xRel = -centerImg_center(2)+player_x;
        
        
        playerAngle = 180 / pi * atan(yRel/xRel);
        if xRel < 0
            playerAngle = playerAngle + 180;
        elseif xRel >= 0 && yRel < 0
            playerAngle = 360 + playerAngle;
        end
        
        if previousMove == 0 % No movement, no adjustment
           
        elseif previousMove == 1 % Moved left, positive adjust
            movedDist = 360/(rotationSpeed*framerate);
            playerAngle = playerAngle+movedDist;
            if playerAngle >= 360
                playerAngle = playerAngle - 360;
            end
        elseif previousMove == 2 % Moved right, negative adjust
            movedDist = 360/(rotationSpeed*framerate);
            playerAngle = playerAngle-movedDist;
            if playerAngle < 0
                playerAngle = playerAngle + 360;
            end
        end
        %if mod(i,10) == 0
            %disp(['PLAYER AT Theta = ' num2str(playerAngle)]);
        %end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %break;
    
    % Remove player from image so it doesn't interfere
    xRemoveRel = player_x + x_half - round(centerImg_size(2)/2);
    yRemoveRel = player_y + y_half - round(centerImg_size(1)/2);
    yRemovePixels = round(centerImg_size(1)/13);
    xRemovePixels = round(centerImg_size(2)/13);
    capture_img(yRemoveRel-yRemovePixels:yRemoveRel+yRemovePixels,xRemoveRel-xRemovePixels:xRemoveRel+xRemovePixels) = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    wallDistance = zeros(1, numSides);
    wallDistance = wallDistance - 1;
    startRadius = centerSize + 15;
    for wall = 1:numSides
        idealAngle = idealAngles(wall);
        if abs(cosd(idealAngle))/x_half > abs(sind(idealAngle))/y_half % Max x will reach first
            max_radius = floor(abs(x_half/cosd(idealAngle))); 
        else
            max_radius = floor(abs(y_half/sind(idealAngle)));
        end
        
        %%%%%%%%%%%%%%%%
        % RECORDING
        xVal = floor(startRadius * cosd(idealAngle)) + x_center;
        yVal = -floor(startRadius * sind(idealAngle)) + y_center;
        startingWall_list(wall,:,i) = [yVal, xVal];
        %%%%%%%%%%%%%%%%
        
        for r = startRadius:max_radius-3
            xVal = floor(r * cosd(idealAngle)) + x_center;
            yVal = -floor(r * sind(idealAngle)) + y_center;
            if capture_img(yVal, xVal) == 0
                wallDistance(wall) = r-startRadius;
                break;
            end
            
        end
        if wallDistance(wall) == -1
            %wallDistance(wall) = max_radius-startRadius-2;
            wallDistance(wall) = diag_length-startRadius;
        end
        
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Wall velocity = negative if no wall now   
    if numSides == numSidesPrevious
        
        % Check if rotation changed walls
        % previousMove
        
        
        wallVelocity = wallDistancePrevious - wallDistance;
        wallVelocity(wallVelocity<0) = 0; % No negatives
    else % numSides changed! Must recalibrate
        wallVelocity = zeros(1, numSides);
        disp(['numSides changed to ' int2str(numSides)]);       
    end
    
    playerAnglePrevious = playerAngle;
    
    % DEGUG
    debug = 1;
    wallVelocity(:) = 17;
    
    numSidesPrevious = numSides;
    wallDistancePrevious = wallDistance;
    
    debug = 1;
    wallDistance_list(1:numSides,i) = wallDistance;
    
    %disp(wallVelocity);
    

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Act on information
    %wallAngles = [45 135 225 315];
    %idealAngles = [0 90 180 270];

    %tic;
    for j = 1:size(wallAngles,2)
       if wallAngles(j) > playerAngle
          playerWallPosition = j;
          break; 
       end
    end
    if playerWallPosition == 0
       playerWallPosition = 1;
    end
    
    playerWall_list(i) = playerWallPosition;

    movingChoice = 0; % 0 = No move, 1 = left, 2 = right
    % Approx 0.15 seconds to move 90 degrees
    [bestMoveDistance, bestMoveLocation] = max(wallDistance);

    bestMove_list(i) = bestMoveLocation;
    
    if bestMoveLocation == playerWallPosition
        % Don't move
        movingChoice = 0;
        %disp('No move');
    else

        rightMove = mod(playerWallPosition-1,numSides);
        if rightMove == 0
            rightMove = numSides;
        end
        rightMoveAngle = wallAngles(rightMove);
        leftMoveAngle = wallAngles(playerWallPosition);
        curWallDistance = wallDistance(playerWallPosition);
        rightMoveDist = abs(playerAngle - rightMoveAngle);
        if rightMoveDist > 180
            rightMoveDist = 360 - rightMoveDist;
        end
        leftMoveDist = abs(playerAngle - leftMoveAngle);
        if leftMoveDist > 180
            leftMoveDist = 360 - leftMoveDist;
        end

        % In seconds
        costPerDegree = framerate * wallVelocity * rotationSpeed / 360;
        costPerSide = costPerDegree * 360 / numSides;

        rightMoveCost = rightMoveDist * costPerDegree(playerWallPosition);
        leftMoveCost = leftMoveDist * costPerDegree(playerWallPosition);

        leftClose = 0;
        rightClose = 0;

        %disp([leftMoveCost rightMoveCost]);
        if wallDistance(playerWallPosition) - leftMoveCost < player_closeness_threshold
            leftClose = 1;
        end
        if wallDistance(playerWallPosition) - rightMoveCost < player_closeness_threshold
            rightClose = 1;
        end

        if lockFrames == 0
            if leftClose == 1 && rightClose == 1 % Worst case scenario: Imminent death
                %disp('Imminent Defeat');
                % Panic move: Must act fast
                if leftMoveCost <= rightMoveCost
                    % Move Left
                    movingChoice = 1;
                    setLockFrames = 2;
                    %disp('Super Panic Move Left');
                else
                    % Move Right
                    movingChoice = 2;
                    setLockFrames = 2;
                    %disp('Super Panic Move Right');
                end
            elseif leftClose == 1
                % Move Right
                movingChoice = 2;
                setLockFrames = 2;
                %disp('Panic Move Right');
            elseif rightClose == 1
                % Move Left
                movingChoice = 1;
                setLockFrames = 2;
                %disp('Panic Move Left');
            else % Currently safe, can now figure out best move timely    


                leftMovesCost = zeros(1, numSides);
                rightMovesCost = zeros(1, numSides);


                temp = circshift(wallDistance', [1-playerWallPosition, 0]);
                leftMovesDist = temp';
                temp = circshift(wallDistance', [numSides-playerWallPosition, 0]);
                rightMovesDist = temp';
                rightMovesDist = fliplr(rightMovesDist);
                rightMovesDist = rightMovesDist - 1; % PENALIZE TO AVOID EQUALS

                leftCost = circshift(costPerSide', [1-playerWallPosition, 0]);
                leftCost = leftCost';
                rightCost = circshift(costPerSide', [numSides-playerWallPosition, 0]);
                rightCost = rightCost';
                rightCost = fliplr(rightCost);

                for side = 2:numSides
                   leftMovesCost(side) = leftMovesCost(side-1) + leftCost(side); % Cost to get to end of side
                   rightMovesCost(side) = rightMovesCost(side-1) + rightCost(side);  
                end
                leftMovesCost = leftMovesCost + leftMoveCost; % Cost to get to start of side
                rightMovesCost = rightMovesCost + rightMoveCost; % Cost to get to start of side
                leftMovesCost(1) = 0; % Where player is, 0 cost cause they are already there
                rightMovesCost(1) = 0; % Where player is, 0 cost cause they are already there

                leftMovesNet = leftMovesDist - leftMovesCost;
                rightMovesNet = rightMovesDist - rightMovesCost;

                maxLeftDist = -1;
                maxLeftSide = -1;
                for side = 2:numSides
                   curDist = leftMovesDist(side);
                   curSide = side;
                   if leftMovesNet(side) < player_closeness_threshold % == too risky
                        break;
                   elseif maxLeftDist < curDist
                        maxLeftDist = curDist;
                        maxLeftSide = curSide;
                   end
                end

                maxRightDist = -1;
                maxRightSide = -1;
                for side = 2:numSides
                   curDist = rightMovesDist(side);
                   curSide = side;
                   if rightMovesNet(side) < player_closeness_threshold % == too risky
                        break;
                   elseif maxRightDist < curDist
                        maxRightDist = curDist;
                        maxRightSide = curSide;
                   end
                end

                if maxLeftDist > maxRightDist
                   % Move Left
                   movingChoice = 1;
                   %disp('Move Left');
                elseif maxRightDist > maxLeftDist
                   % Move Right
                   movingChoice = 2;
                   %disp('Move Right');
                else % If they are equal
                    if leftMoveDist == -1 % Both can't move to new locations
                        % Don't Move
                        movingChoice = 0;
                        %disp('No Move');
                    elseif maxLeftSide < maxRightSide % If can get there sooner on left side
                        % Move Left
                        movingChoice = 1;
                        %disp('Move Left');
                    elseif maxRightSide < maxLeftSide % If can get there sooner on right side    
                        % Move Right
                        movingChoice = 2;
                        %disp('Move Right');
                    elseif leftMoveCost <= rightMoveCost % Else equal, thus find even smaller differences
                        % Move Left
                        movingChoice = 1;
                        %disp('Move Left');
                    else 
                        % Move Right
                        %movingChoice = 2;
                        %disp('Move Right');
                        %%%%%%%%%%%
                        % HACK: Move Left anyways when safe,
                        % Avoids pinging back and forth
                        movingChoice = 1;
                        %disp('Move Left');
                        %%%%%%%%%%%
                    end
                end
            end
        end
    end
    %toc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if lockFrames == 0
        if movingChoice == 1 % Left
            movingLeft = 1;
            if movingRight == 1
                keyaction('right', 'release');
                movingRight = 0;
            end
            keyaction('left', 'press');
        elseif movingChoice == 2 % Right
            movingRight = 1;
            if movingLeft == 1
                keyaction('left', 'release');
                movingLeft = 0;
            end
            keyaction('right', 'press'); 
        % Fix angle if safe
        elseif movingChoice == 0 && playerFound == true % Safe
           % Reposition to the center
           idealAngle = idealAngles(playerWallPosition);
           temp_player_angle = playerAngle;
           if abs(idealAngle - temp_player_angle) > 180 % Fix angles
               if idealAngle > temp_player_angle
                    idealAngle = idealAngle - 360;
               else
                    temp_player_angle = temp_player_angle - 360;
               end
           end
           %disp(idealAngle - temp_player_angle);
           %{
           if temp_player_angle > wallAngles(size(wallAngles,2)) % Fix circular angle
               temp_player_angle = temp_player_angle - 360;
           end
           %}
           if idealAngle - temp_player_angle > centering_threshold % Move player left
                movingLeft = 1;
                if movingRight == 1
                    keyaction('right', 'release');
                    movingRight = 0;
                end
                keyaction('left', 'press');
           elseif idealAngle - temp_player_angle < -centering_threshold % Move player right
                movingRight = 1;
                if movingLeft == 1
                    keyaction('left', 'release');
                    movingLeft = 0;
                end
                keyaction('right', 'press');
           else
                if movingLeft == 1
                    keyaction('left', 'release');
                    movingLeft = 0;
                end
                if movingRight == 1
                    keyaction('right', 'release');
                    movingRight = 0;
                end    
           end

        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if setLockFrames ~= 0;
        lockFrames = setLockFrames+1;
        setLockFrames = 0;
    end
    %toc;
    
    movingChoice_list(i) = movingChoice;
    
    previousMove = movingChoice;
    
end




% VIDEO COMPILING






vw = VideoWriter('test.avi');
open(vw);
for f = 1:frames
    %rgb=video_img(:,:,[1 1 1],f);
    rgbImage = uint8(cat(3, video_img(:,:,f), video_img(:,:,f), video_img(:,:,f)));
    %for x = 1:200
    %   rgbImage(1:(x*2),1:(x),3) = x; 
    %end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WALL CORNERS
    thetaDiff = 360/numWalls_list(f);
    wallAngles = 0:numWalls_list(f)-1;
    wallAngles = wallAngles * thetaDiff;
    wallAngles = wallAngles + first_wall_list(f);
    
    idealAngles = wallAngles - thetaDiff/2;
    if idealAngles(1) < 0
        idealAngles(1) = idealAngles(1) + 360;
    end   
    
    %wallAngles = fliplr(wallAngles);
    %idealAngles = fliplr(idealAngles);
    %idealAngles = circshift(idealAngles(:),1);
    
    for angle = 1:numWalls_list(f)
        wallX = floor(x_center + centerSize_list(f)*cosd(wallAngles(angle)));
        %wallY = floor(y_center + centerSize_list(f)*sind(wallAngles(angle)));
        wallY = floor(y_center - centerSize_list(f)*sind(wallAngles(angle)));
        
        if angle == 1
            rgbImage(wallY-10:wallY+10,wallX-10:wallX+10,2) = 0;
        elseif angle == 2
            rgbImage(wallY-10:wallY+10,wallX-10:wallX+10,1) = 125;
            rgbImage(wallY-10:wallY+10,wallX-10:wallX+10,3) = 0;
        else
            rgbImage(wallY-10:wallY+10,wallX-10:wallX+10,3) = 0;
        end
        
        %{
        wallStartY = startingWall_list(angle,1,f);
        wallStartX = startingWall_list(angle,2,f);
        rgbImage(wallStartY-10:wallStartY+10,wallStartX-10:wallStartX+10,2) = floor(angle/numWalls_list(f)*255);
        rgbImage(wallStartY-10:wallStartY+10,wallStartX-10:wallStartX+10,1) = 0;
        %}
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLAYER
    
    yPlayer = player_list(1,f);
    xPlayer = player_list(2,f);
    
    yPlayer = y_center-centerImg_center(1)+yPlayer;
    xPlayer = x_center-centerImg_center(2)+xPlayer;
    rgbImage(yPlayer-10:yPlayer+10,xPlayer-10:xPlayer+10,2) = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pathfinding
    
     
    bestMove = bestMove_list(f);
    
    
    for angle = 1:numWalls_list(f)
        curWall = wallDistance_list(angle,f)/sqrt(y_half^2+x_half^2);
        idealX = floor(x_center + centerSize_list(f)*cosd(idealAngles(angle)));
        %idealY = floor(y_center + centerSize_list(f)*sind(idealAngles(angle)));
        idealY = floor(y_center - centerSize_list(f)*sind(idealAngles(angle))); 
        if angle == bestMove
            rgbImage(idealY-10:idealY+10,idealX-10:idealX+10,1) = 0;
            rgbImage(idealY-10:idealY+10,idealX-10:idealX+10,2) = curWall*255;
            rgbImage(idealY-10:idealY+10,idealX-10:idealX+10,3) = curWall*255; 
        else   
            rgbImage(idealY-10:idealY+10,idealX-10:idealX+10,1) = curWall*255;
            rgbImage(idealY-10:idealY+10,idealX-10:idealX+10,2) = curWall*255;
            rgbImage(idealY-10:idealY+10,idealX-10:idealX+10,3) = curWall*255;
        end
    end
    
    %temp1 = 1:numWalls_list(f);
    
    
    
    %playerWall_list(f)
    
    playerX = floor(x_center + centerSize_list(f)*cosd(idealAngles(playerWall_list(f))));
    %playerY = floor(y_center + centerSize_list(f)*sind(idealAngles(playerWall_list(f))));
    playerY = floor(y_center - centerSize_list(f)*sind(idealAngles(playerWall_list(f))));
    
    rgbImage(playerY-5:playerY+5,playerX-5:playerX+5,1) = 255;
    rgbImage(playerY-5:playerY+5,playerX-5:playerX+5,2) = 0;
    rgbImage(playerY-5:playerY+5,playerX-5:playerX+5,3) = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Player movements
    rgbImage(y_center-10:y_center+10,x_center-20:x_center+20,1) = 230;
    rgbImage(y_center-10:y_center+10,x_center-20:x_center+20,2) = 230;
    rgbImage(y_center-10:y_center+10,x_center-20:x_center+20,3) = 230;
    if movingChoice_list(f) == 0
        rgbImage(y_center-10:y_center+10,x_center-10:x_center+10,1) = 0;
        rgbImage(y_center-10:y_center+10,x_center-10:x_center+10,2) = 255;
        rgbImage(y_center-10:y_center+10,x_center-10:x_center+10,3) = 255;
    elseif movingChoice_list(f) == 1
        rgbImage(y_center-10:y_center+10,x_center-20:x_center,1) = 255;
        rgbImage(y_center-10:y_center+10,x_center-20:x_center,2) = 0;
        rgbImage(y_center-10:y_center+10,x_center-20:x_center,3) = 0;
    elseif movingChoice_list(f) == 2
        rgbImage(y_center-10:y_center+10,x_center:x_center+20,1) = 255;
        rgbImage(y_center-10:y_center+10,x_center:x_center+20,2) = 0;
        rgbImage(y_center-10:y_center+10,x_center:x_center+20,3) = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    writeVideo(vw,rgbImage);
    if mod(f,10) == 0
       disp(['f = ' int2str(f)]); 
    end
end
close(vw);







