% Holds down left key for seconds, then releases.
function keyholdleft(seconds)
	robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_LEFT);
    pause(seconds);
    robot.keyRelease(java.awt.event.KeyEvent.VK_LEFT);  
end