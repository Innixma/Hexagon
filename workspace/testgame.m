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


frames = 60000; % How long code runs
framerate = 40; % Approximate amount of frames processed per second
numSides = 4;
image_threshold = 0.5; % From 1 to 0, threshold is more strict with higher number


% Lower value = More picky with its position, more prone to error
centering_threshold = 25; % Angle away from the center of a safe side that the AI is content with being.

% seconds to go 360 degrees:
rotationSpeed = 0.62;

% Lower value = More risky in its movements
player_closeness_threshold = 55;

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
wallDistancePrevious = zeros(1, numSides);
numSidesPrevious = numSides;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_half = round(x_max/2);
y_half = round(y_max/2);
x_center = x_half;
y_center = y_half;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:frames
    %tic;
    if mod(i,100) == 1
        tic;
    elseif mod(i,100) == 0
        timeElapsed = toc;
        framerate = round(100 / timeElapsed);
        disp(['Framerate = ' int2str(framerate)]);
    end
    playerWallPosition = 0;
    
    if lockFrames ~= 0
        lockFrames = lockFrames - 1;
    end
    %tic;
    capture_img = screencapture(x_offset, y_offset, x_max, y_max);
    % make it binary
    
    capture_img = im2bw(capture_img, image_threshold);
    
    %capture_img = imcomplement(capture_img);
    
    %leftImg = capture_img(y_center, 1:x_center);
    %rightImg = capture_img(y_center, x_center+1:x_max);
    %upImg = capture_img(1:y_center, x_center);
    %downImg = capture_img(y_center+1:y_max, x_center);
    %centerImg = capture_img(y_center-y_max/10+3:y_center+y_max/10-3,x_center-y_max/10-35:x_center+y_max/10+35);
    centerImg = capture_img(y_center-center_areafix_y:y_center+center_areafix_y,x_center-center_areafix_x:x_center+center_areafix_x);
    centerImg_size = size(centerImg);
    centerImg_center = floor(centerImg_size/2);
    
    %centerImg(centerImg_center(1)-54:centerImg_center(1)+58,centerImg_center(2)-78:centerImg_center(2)+80) = 1;
    %centerImg(centerImg_center(1)-center_boxfix_y:centerImg_center(1)+center_boxfix_y,centerImg_center(2)-center_boxfix_x:centerImg_center(2)+center_boxfix_x) = 1;
    
    
    
    %imshow(capture_img);
    %imshow(centerImg);
    %break;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Center
    
    [centerSize, numSides, wallAngles] = centerboxFinal(centerImg);
    
    if numSides < 3
        disp('Waiting for game to start')
        continue;
    end
    idealAngles = zeros(1,numSides);
    idealAngles(1) = mod(360 - wallAngles(numSides)-wallAngles(1),360);
    for j = 2:numSides
       idealAngles(j) = (wallAngles(j-1) + wallAngles(j)) / 2; 
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Player
    %tic
    [player_x, player_y] = detect_player_nick(centerImg);
    %toc
    if player_x == -1
        playerFound = false;
        disp('Player not found!');
    else
        playerFound = true;
    end
    
    %break;
    
    %tic
    % Remove player from image so it doesn't interfere
    xRemoveRel = player_x + x_half - round(centerImg_size(2)/2);
    yRemoveRel = player_y + y_half - round(centerImg_size(1)/2);
    yRemovePixels = round(centerImg_size(1)/16);
    xRemovePixels = round(centerImg_size(2)/16);
    capture_img(yRemoveRel-yRemovePixels:yRemoveRel+yRemovePixels,xRemoveRel-xRemovePixels:xRemoveRel+xRemovePixels) = 1;
    %toc
    
    %imshow(capture_img);
    %break;
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    wallDistance = zeros(1, numSides);
    wallDistance = wallDistance - 1;
    for wall = 1:numSides
        idealAngle = idealAngles(wall);
        startRadius = centerSize + 23;
        if abs(cosd(idealAngle))/x_half > abs(sind(idealAngle))/y_half % Max x will reach first
            max_radius = floor(abs(x_half/cosd(idealAngle))); 
        else
            max_radius = floor(abs(y_half/sind(idealAngle)));
        end
        
        for r = startRadius:max_radius-3
            xVal = floor(r * cosd(idealAngle)) + x_half;
            yVal = -floor(r * sind(idealAngle)) + y_half;
            if capture_img(yVal, xVal) == 0
                wallDistance(wall) = r-startRadius;
                break;
            end
            
        end
        if wallDistance(wall) == -1
            wallDistance(wall) = max_radius-startRadius-2;
        end
        
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Wall velocity = negative if no wall now
    
    if numSides == numSidesPrevious
        wallVelocity = wallDistancePrevious - wallDistance;
        wallVelocity(wallVelocity<0) = 0; % No negatives
    else % numSides changed! Must recalibrate
        wallVelocity = zeros(1, numSides);
        disp(['numSides changed to ' int2str(numSides)]);
    end
    
    numSidesPrevious = numSides;
    wallDistancePrevious = wallDistance;
    
    %disp(wallVelocity);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate Player Angle
    if playerFound == true
        xRel = player_x - round(centerImg_size(2)/2);
        yRel = -player_y + round(centerImg_size(1)/2);

        playerAngle = 180 / pi * atan(yRel/xRel);
        if xRel < 0 && yRel < 0
            playerAngle = playerAngle + 180;
        elseif xRel < 0 && yRel >= 0
            playerAngle = 180 + playerAngle;
        elseif xRel >= 0 && yRel < 0
            playerAngle = 360 + playerAngle;
        end
        %if mod(i,10) == 0
            %disp(['PLAYER AT Theta = ' num2str(playerAngle)]);
        %end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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

    movingChoice = 0; % 0 = No move, 1 = left, 2 = right
    % Approx 0.15 seconds to move 90 degrees
    [bestMoveDistance, bestMoveLocation] = max(wallDistance);

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
                    disp('Super Panic Move Left');
                else
                    % Move Right
                    movingChoice = 2;
                    setLockFrames = 2;
                    disp('Super Panic Move Right');
                end
            elseif leftClose == 1
                % Move Right
                movingChoice = 2;
                setLockFrames = 2;
                disp('Panic Move Right');
            elseif rightClose == 1
                % Move Left
                movingChoice = 1;
                setLockFrames = 2;
                disp('Panic Move Left');
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
                        disp('Move Left');
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
end

