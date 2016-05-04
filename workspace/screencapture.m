function [img] = screencapture(x,y,w,h)
% Use java.awt.Robot to take a screen-capture of the specified screen area
if nargin == 0
    t = java.awt.Toolkit.getDefaultToolkit();
    rect = java.awt.Rectangle(t.getScreenSize());
else
    rect = java.awt.Rectangle(x,y,w,h);
end
robot = java.awt.Robot;
jimg = robot.createScreenCapture(rect);

h = jimg.getHeight;
w = jimg.getWidth;

data = reshape(typecast(jimg.getData.getDataStorage, 'uint8'), 4, w, h);
% img = cat(3, ...
%     transpose(reshape(data(3, :, :), w, h)), ...
%     transpose(reshape(data(2, :, :), w, h)), ...
%     transpose(reshape(data(1, :, :), w, h)));
% img = rgb2gray(img);
img = transpose(reshape(data(2,:,:),w,h));
end

