
numSides = 4;
framerate = 40;
wallDistance = [20 50 800 200];
playerAngle = 43;
wallVelocity = [7 7 7 7]; 
wallDistancePrevious = wallDistance;
player_closeness_threshold = 30;

wallAngles = [45 135 225 315];
idealAngles = [0 90 180 270];

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

% Approx 0.15 seconds to move 90 degrees
[bestMoveDistance, bestMoveLocation] = max(wallDistance);

if bestMoveLocation == playerWallPosition
    % Don't move
    disp('No move');
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
    costPerDegree = framerate * wallVelocity * 0.6 / 360;
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
    
    if leftClose == 1 && rightClose == 1 % Worst case scenario: Imminent death
        %disp('Imminent Defeat');
        % Panic move: Must act fast
        if leftMoveCost <= rightMoveCost
            % Move Left
            disp('Super Panic Move Left');
        else
            % Move Right
            disp('Super Panic Move Right');
        end
    elseif leftClose == 1
        % Move Right
        disp('Panic Move Right');
    elseif rightClose == 1
        % Move Left
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
           disp('Move Left');
        elseif maxRightDist > maxLeftDist
           % Move Right
           disp('Move Right');
        else % If they are equal
            if leftMoveDist == -1 % Both can't move to new locations
                % Don't Move
                disp('No Move');
            elseif maxLeftSide < maxRightSide % If can get there sooner on left side
                % Move Left
                disp('Move Left');
            elseif maxRightSide < maxLeftSide % If can get there sooner on right side    
                % Move Right
                disp('Move Right');
            elseif leftMoveCost <= rightMoveCost % Else equal, thus find even smaller differences
                % Move Left
                disp('Move Left');
            else 
                % Move Right
                %disp('Move Right');
                
                %%%%%%%%%%%
                % HACK: Move Left anyways
                disp('Move Left');
                %%%%%%%%%%%
            end
        end
    end
end
%toc;





