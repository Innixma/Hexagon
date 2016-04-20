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

if mod(x_max,2) ~= 0
    x_max = x_max - 1;   
end
if mod(y_max,2) ~= 0
    y_max = y_max - 1;   
end


frames = 12000; % How long code runs
image_threshold = 0.5; % From 1 to 0, threshold is more strict with higher number

% Lower value = More picky with its position, more prone to error
centering_threshold = 40; % Angle away from the center of a safe side that the AI is content with being.

%center_areafix_x = round(x_max/10)-55; % Change these two variables to accurately include center box and player for player detection
center_areafix_x = round(x_max/10)-30;
center_areafix_y = round(y_max/10)+6;

% These params don't matter for Danesh, make them = 1
center_boxfix_x = round(center_areafix_x/1.25); % Change these two variables to accurately remove center box from player detection
center_boxfix_y = round(center_areafix_y/1.25); % Too large of values will also remove the player, so be careful

wall_start_x = center_areafix_x + 10; % Increase if wall finder is detecting the player as a wall
wall_start_y = center_areafix_y + 10;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization Variables
closeleft = 0;
closeright = 0;
closeup = 0;
closedown = 0;
movingLeft = 0;
movingRight = 0;
player_angle = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_half = round(x_max/2);
y_half = round(y_max/2);
x_center = x_half;
y_center = y_half;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:frames
    %tic;
    playerWallPosition = 0;
    leftWall = 0;
    rightWall = 0; 
    upWall = 0;
    downWall = 0;
    
    %tic;
    capture_img = screencapture(x_offset, y_offset, x_max, y_max);
    % make it binary
    
    capture_img = im2bw(capture_img, image_threshold);
    
    %capture_img = imcomplement(capture_img);
    
    leftImg = capture_img(y_center, 1:x_center);
    rightImg = capture_img(y_center, x_center+1:x_max);
    upImg = capture_img(1:y_center, x_center);
    downImg = capture_img(y_center+1:y_max, x_center);
    %centerImg = capture_img(y_center-y_max/10+3:y_center+y_max/10-3,x_center-y_max/10-35:x_center+y_max/10+35);
    centerImg = capture_img(y_center-center_areafix_y:y_center+center_areafix_y,x_center-center_areafix_x:x_center+center_areafix_x);
    centerImg_size = size(centerImg);
    centerImg_center = floor(centerImg_size/2);
    
    %centerImg(centerImg_center(1)-54:centerImg_center(1)+58,centerImg_center(2)-78:centerImg_center(2)+80) = 1;
    %centerImg(centerImg_center(1)-center_boxfix_y:centerImg_center(1)+center_boxfix_y,centerImg_center(2)-center_boxfix_x:centerImg_center(2)+center_boxfix_x) = 1;
    
    tic
    detect_player_nick(centerImg);
    toc
    
    %imshow(capture_img);
    %imshow(centerImg);
    break;

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
    for x = -x_half+wall_start_x:-1
       if leftImg(1,-x) ~= 1
            leftWall = 1;
            if mod(i,10) == 0
                disp(['Left Wall! x = ' int2str(-x)]);
            end
            
            if x <= -x_half+wall_start_x % If wall disrupts player detection!
                %disp('CLOSE LEFT');
                closeleft = 3;
            end
            break;
       end
    end
    for x = wall_start_x:x_half
       if rightImg(1,x) ~= 1
            rightWall = 1; 
            if mod(i,10) == 0
                disp(['Right Wall! x = ' int2str(x+x_half)]);
            end
            if x <= wall_start_x % If wall disrupts player detection!
                %disp('CLOSE RIGHT');
                closeright = 3;
            end
            break;
       end
    end
    for y = -y_half+wall_start_y:-1
       if upImg(-y,1) ~= 1
            upWall = 1;
            if mod(i,10) == 0
                disp(['Up Wall! y = ' int2str(-y)]);
            end
            if y <= -y_half+wall_start_y % If wall disrupts player detection!
                %disp('CLOSE UP');
                closeup = 3;
            end
            break;
       end
    end
    for y = wall_start_y:y_half % Edited this due to my taskbar being black. Fix in future
       if downImg(y,1) ~= 1
            downWall = 1;
            if mod(i,10) == 0
                disp(['Down Wall! y = ' int2str(y+510)]);
            end
            if y <= wall_start_y % If wall disrupts player detection!
                %disp('CLOSE DOWN');
                closedown = 3;
            end
            break;
       end
    end
    
    % Find Player
    %tic
    xMax = length(centerImg(1,:));
    yMax = length(centerImg(:,1));
    
    % Walls can enter players area, so need to consider them
    pixelCount = 0;
    playerFound = false;
    playerCoords = [0 0];
    if closeleft == 0 && closeright == 0 && closeup == 0 && closedown == 0
        for y = 1:yMax
            for x = 1:xMax
                if centerImg(y,x) ~= 1
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

        player_angle = 180 / pi * atan(yRel/xRel);
        if xRel < 0 && yRel < 0
            player_angle = player_angle + 180;
        elseif xRel < 0 && yRel >= 0
            player_angle = 180 + player_angle;
        elseif xRel >= 0 && yRel < 0
            player_angle = 360 + player_angle;
        end
        if mod(i,10) == 0
            disp(['PLAYER AT Theta = ' num2str(player_angle)]);
        end
    end
    
    % Act on information
    wallAngles = [45 135 225 315];
    idealAngles = [0 90 180 270];
    for j = 1:size(wallAngles,2)
       if wallAngles(j) > player_angle
          playerWallPosition = j;
          break; 
       end
    end
    if playerWallPosition == 0
       %playerWallPosition = size(wallAngles);
       playerWallPosition = 1;
    end
    
    
    
    
    %playerWallPosition = floor(mod(angle+44.9,360)/90)+1;
    %disp(playerWallPosition);
    dangerZones = [rightWall upWall leftWall downWall];
    
    if dangerZones(playerWallPosition) == 1 % Wall incoming
        disp('DANGER');
        if dangerZones(mod(playerWallPosition,4)+1) == 0 % Left neighbor
            movingLeft = 1;
            if movingRight == 1
                keyaction('right','release');
                movingRight = 0;
            end
            keyaction('left','press');
        else
            movingRight = 1;
            if movingLeft == 1
                keyaction('left', 'release');
                movingLeft = 0;
            end
            keyaction('right','press');
        end
    else
        if movingLeft == 1
            keyaction('left','release');
            movingLeft = 0;
        end
        if movingRight == 1
            keyaction('right','release');
            movingRight = 0;
        end
    end
    
    % Fix angle if safe
    if dangerZones(playerWallPosition) == 0 && playerFound == true % Safe
       % Reposition to the center
       idealAngle = idealAngles(playerWallPosition);
       temp_player_angle = player_angle;
       if temp_player_angle > wallAngles(size(wallAngles,2)) % Fix circular angle
           temp_player_angle = temp_player_angle - 360;
       end
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
    
    %toc;
end

