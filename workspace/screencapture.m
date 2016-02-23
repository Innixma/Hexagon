% Usage:
% screencapture()
% screencapture(0, 0, 100, 100)
% returns: matlab RGB image matrix
function img = screencapture(x, y, w, h)
    robot = java.awt.Robot;

    if nargin == 0
        t = java.awt.Toolkit.getDefaultToolkit();
        rect = java.awt.Rectangle(t.getScreenSize());
    else
        rect = java.awt.Rectangle(x,y,w,h);
    end

    % capture BufferedImage of screen
    capture = robot.createScreenCapture(rect);
    
    if nargout
        h = capture.getHeight();
        w = capture.getWidth();
        % convert BufferedImage into matlab RGB
        data = capture.getRGB(0,0,w,h,[],0,w); 
        data = 256^3 + data;
        B = uint8(mod(data, 256));
        G = uint8(mod((data - int32(B))./256, 256));
        R = uint8(mod((data - 256 * int32(G)) ./ 65536, 256));
        img = uint8(zeros(h, w, 3));
        img(:,:,1) = reshape(R, [w h])';
        img(:,:,2) = reshape(G, [w h])';
        img(:,:,3) = reshape(B, [w h])';
    end
end
