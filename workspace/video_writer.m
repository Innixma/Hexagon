V = zeros(100,100,100);

% run testgame.m frame by frame
% say we have some frame F for frame number f
V(:,:,f) = F;

% now we're done so write to file
vw = VideoWriter('test.avi');
open(vw);
for f = 1:frames
	writeVideo(vw,V(:,:,f));
end
close(vw);