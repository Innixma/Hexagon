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


frames = 3000; % How long code runs
closeleft = 0;
closeright = 0;
closeup = 0;
closedown = 0;
movingLeft = 0;
movingRight = 0;
angle = 0;

for i = 1:frames
    %tic;
    playerWallPosition = 0;
    leftWall = 0;
    rightWall = 0; 
    upWall = 0;
    downWall = 0;

    leftImg = rgb2gray(screencapture(0, 540, 960, 1));
    rightImg = rgb2gray(screencapture(960, 540, 960, 1));
    upImg = rgb2gray(screencapture(960, 0, 1, 540));
    downImg = rgb2gray(screencapture(960, 540, 1, 540));
    centerImg = rgb2gray(screencapture(823, 441, 275, 188)); % 60,37 out from square
    centerImg(36:146, 59:216) = 255; % Remove center box to find player
    
    if closeleft > 0
        closeleft = closeleft - 1;
    end
    if closeright > 0
        closeright = closeright - 1;
    end
    if closeup > 0
        closeup = closeup - 1;
    end
    if closedown > 0
        closedown = closedown - 1;
    end
    
    % Find Walls
    for x = -810:-1
       if leftImg(1,-x) ~= 255
            leftWall = 1;
            if mod(i,10) == 0
                disp(['Left Wall! x = ' int2str(-x)]);
            end
            
            if x <= -790 % If wall disrupts player detection!
                %disp('CLOSE LEFT');
                closeleft = 3;
            end
            break;
       end
    end
    for x = 150:960
       if rightImg(1,x) ~= 255
            rightWall = 1; 
            if mod(i,10) == 0
                disp(['Right Wall! x = ' int2str(x+960)]);
            end
            if x <= 170 % If wall disrupts player detection!
                %disp('CLOSE RIGHT');
                closeright = 3;
            end
            break;
       end
    end
    for y = -400:-1
       if upImg(-y,1) ~= 255
            upWall = 1;
            if mod(i,10) == 0
                disp(['Up Wall! y = ' int2str(-y)]);
            end
            if y <= -400 % If wall disrupts player detection!
                %disp('CLOSE UP');
                closeup = 3;
            end
            break;
       end
    end
    for y = 140:490 % Edited this due to my taskbar being black. Fix in future
       if downImg(y,1) ~= 255
            downWall = 1;
            if mod(i,10) == 0
                disp(['Down Wall! y = ' int2str(y+540)]);
            end
            if y <= 140 % If wall disrupts player detection!
                %disp('CLOSE DOWN');
                closedown = 3;
            end
            break;
       end
    end
    
    % Find Player
    %tic
    xMax = length(centerImg);
    yMax = length(centerImg(:,1));
    
    % Walls can enter players area, so need to consider them
    pixelCount = 0;
    playerFound = false;
    playerCoords = [0 0];
    if closeleft == 0 && closeright == 0 && closeup == 0 && closedown == 0
        for y = 1:yMax
            for x = 1:xMax
                if centerImg(y,x) ~= 255
                    % FOUND PLAYER PIXEL
                    playerFound = true;
                    xRel = x - xMax/2;
                    yRel = yMax/2 - y;
                    pixelCount = pixelCount+1;
                    playerCoords = playerCoords + [xRel yRel];
                    
                end
            end
        end
    end
    %toc
    
    % Calculate Player Angle
    if playerFound == true
        xRel = playerCoords(1)/pixelCount;
        yRel = playerCoords(2)/pixelCount;
        
        
        %xRel = x - xMax/2;
        %yRel = yMax/2 - y;

        angle = 180 / pi * atan(yRel/xRel);
        if xRel < 0 && yRel < 0
            angle = angle + 180;
        elseif xRel < 0 && yRel >= 0
            angle = 180 + angle;
        elseif xRel >= 0 && yRel < 0
            angle = 360 + angle;
        end
        if mod(i,10) == 0
            disp(['PLAYER AT Theta = ' num2str(angle)]);
        end
    end
    
    % Act on information
    wallAngles = [45 135 225 315];
    for j = 1:size(wallAngles)
       if wallAngles(j) > angle
          playerWallPosition = j;
          break; 
       end
    end
    if playerWallPosition == 0
       playerWallPosition = size(wallAngles); 
    end
    
    
    
    
    %playerWallPosition = floor(mod(angle+44.9,360)/90)+1;
    %disp(playerWallPosition);
    dangerZones = [rightWall upWall leftWall downWall];
    
    if dangerZones(playerWallPosition) == 1 % Wall incoming
        disp('DANGER');
        if dangerZones(mod(playerWallPosition,4)+1) == 0 % Left neighbor
            movingLeft = 1;
            if movingRight == 1
                keyreleaseright();
                movingRight = 0;
            end
            keypressleft();
        else
            movingRight = 1;
            if movingLeft == 1
                keyreleaseleft();
                movingLeft = 0;
            end
            keypressright();
        end
    else
        if movingLeft == 1
            keyreleaseleft();
            movingLeft = 0;
        end
        if movingRight == 1
            keyreleaseright();
            movingRight = 0;
        end
    end
    
    
    
end

