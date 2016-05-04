function [centerSize, numSides, wallAngles] = real_centerbox_final_nick4(CropImg)
    % Main code by Danesh, 
    % Heavily modified and optimized by Nick
    % Major rotation bug fixed by Danesh

    centerX = round(size(CropImg, 2)/2);
    centerY = round(size(CropImg, 1)/2);

    %figure; imshow(CropImg); hold on; plot(centerX, centerY, 'rX', 'markersize', 30);

    radius = 30:70;
    lineIntVal = zeros(size(radius));
    thetas = 1:360;
    dists = zeros(size(thetas));

    for i = 1:length(thetas)

        for j = 1:length(radius)        
            lineIntVal(j) = CropImg(floor(centerY + radius(j)*sind(thetas(i))), floor(centerX + radius(j)*cosd(thetas(i))));
            if lineIntVal(j) == 0
                break;
            end
        end

         %plot(centerWallX, centerWallY, 'r.', 'markersize', 30);

        dists(i) = radius(j);
    end

    %figure; plot(dists);
    

% Promising solution:

%highlighting_shift = 5;  % Padding dists with zeros improves findpeaks' ability to find peaks ( it boosts the prominences).  My choice of 5 as the pad was arbitrary, but it seems to work fine.
%augmented_dists = [zeros(1, highlighting_shift) dists zeros(1, highlighting_shift)];

y = dists;
x = 1:360;

%tic
[yu,maxIndex] = max(y);
yl = min(y);
yr = (yu-yl);                               % Range of ‘y’
yz = y-yu+(yr/2);
zx = x(yz .* circshift(yz,[0 1]) <= 0);     % Find zero-crossings
per = 2*mean(diff(zx));                     % Estimate period
ym = mean(y);                               % Estimate offset
%fit = @(b,x)  b(1).*(sin(2*pi*x./b(2) + 2*pi/b(3))) + b(4);    % Function to fit
%fit = @(b,x)  (yr/2).*(sin(2*pi*x./b(1) + 2*pi/b(2))) + b(3);
fit = @(b,x)  (yr/2).*(sin(2*pi*x./b(1) + 2*pi/b(2))) + (ym);
fcn = @(b) sum((fit(b,x) - y).^2);                              % Least-Squares cost function
%toc
%tic
%s = fminsearch(fcn, [yr;  per;  -1;  ym]);                       % Minimise Least-Squares
s = fminsearch(fcn, [per;  -1]);
%toc
xp = linspace(min(x),max(x));

figure(1)
plot(x,y,'b',  xp,fit(s,xp), 'r')
grid

%temp1 = 360*s(2)+ s(1);

%temp2 = (sin(2*pi*45./90 + 2*pi/s(2)));

numSides = round(360/s(1));
wallAngles = zeros(1,numSides);

for side = 1:numSides
    wallAngles(side) = maxIndex+round((side-1)*s(1));    
end

[~,rotateCount] = min(wallAngles);
wallAngles = mod(wallAngles,360);
wallAngles = circshift(wallAngles',-rotateCount+1)';

centerSize = yu;


end
