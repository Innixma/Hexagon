function [centerMax, centerMin, numSides, wallAngles] = centerboxNick(CropImg, maxRadius, minRadius)
    % Dists code by Danesh,
    % Function code by Nick, 
    % Heavily modified and optimized by Nick

    centerX = round(size(CropImg, 2)/2);
    centerY = round(size(CropImg, 1)/2);

    %figure; imshow(CropImg); hold on; plot(centerX, centerY, 'rX', 'markersize', 30);

    radius = minRadius:maxRadius;
    lineIntVal = zeros(size(radius));
    thetas = 1:360;
    y = zeros(size(thetas));

	%% find innermost radial distance of first pixel for each angular bin
    for i = 1:length(thetas)
        for j = 1:length(radius)        
            %lineIntVal(j) = CropImg(floor(centerY + radius(j)*sind(thetas(i))), floor(centerX + radius(j)*cosd(thetas(i))));
            lineIntVal(j) = CropImg(floor(centerY - radius(j)*sind(thetas(i))), floor(centerX + radius(j)*cosd(thetas(i))));
            if lineIntVal(j) == 0
                break;
            end
        end
         %plot(centerWallX, centerWallY, 'r.', 'markersize', 30);
        y(i) = radius(j);
    end

    %figure; plot(dists);

	%% fit a cos wave to the bin data
	x = 1:360;

	[yu,maxIndex] = max(y);
	yl = min(y);
	yr = (yu-yl); % Range of y
	ym = mean(y); % Estimate offset
	fit = @(b,x)  (yr/3).*(cos(2*pi*x./b(1) - 2*pi*maxIndex./b(1))) + (ym); % Function to fit
	fcn = @(b) sum((fit(b,x) - y).^2); % Least-Squares cost function

	s = fminbnd(fcn, 89, 91);
	% @TODO try to fit in a smarter way, not just iterating over every theta

    %xp = linspace(min(x),max(x));
    %figure(1)
    %plot(x,y,'b',  xp,fit(s,xp), 'r')
    %grid

	%% get output into a friendly format

	numSides = round(360/s);
	wallAngles = zeros(1,numSides);

	for side = 1:numSides
		wallAngles(side) = maxIndex+round((side-1)*s(1));    
	end

	wallAngles = mod(wallAngles,360);
	[~,rotateCount] = min(wallAngles);
	wallAngles = circshift(wallAngles',-rotateCount+1)';
	centerMax = yu;
	centerMin = yl;

end
