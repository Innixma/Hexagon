% Holds down right key for seconds, then releases.
function keyholdright(seconds)
	robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_RIGHT);
    pause(seconds);
    robot.keyRelease(java.awt.event.KeyEvent.VK_RIGHT);  
end