
% Early testing, not precise enough.
function keyholda()
	robot = java.awt.Robot;
	%robot.keyPress(java.awt.event.KeyEvent.VK_A);
    tic;
    
    % 700ish per second
    for i = 1:10
        robot.keyPress(java.awt.event.KeyEvent.VK_B);
        robot.delay(1);
        %robot.keyPress(java.awt.event.KeyEvent.VK_LEFT);
        %robot.delay(1);
        %robot.keyPress(java.awt.event.KeyEvent.VK_A);
        %robot.delay(1);
    end
    toc;
    
end