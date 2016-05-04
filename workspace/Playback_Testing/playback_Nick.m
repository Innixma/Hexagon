x_offset = 458;
y_offset = 188;
x_max = 1020;
y_max = 764;

numFrames = 200;

V = zeros(y_max,x_max,numFrames);


% run testgame.m frame by frame
% say we have some frame F for frame number f




for i = 1:numFrames
    
    capture_img = screencapture(x_offset, y_offset, x_max, y_max);
    % make it binary
    
    V(:,:,i) = im2bw(capture_img, image_threshold);
end

disp('all done');

% now we're done so write to file
vw = VideoWriter('test.avi');
open(vw);
for f = 1:numFrames
	writeVideo(vw,V(:,:,f));
end
close(vw);

disp('video done');

