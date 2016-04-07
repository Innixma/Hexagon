function [] = keyaction(key,action,arg)
narginchk(2, 3);
robot = java.awt.Robot;
e = keymap(key);
switch action
    case 'press'
        robot.keyPress(e);
    case 'release'
        robot.keyRelease(e);
    case 'hold'
        robot.keyPress(e);
        if nargin == 3; pause(arg); end;
        robot.keyRelease(e);
    otherwise
        error('unknown action: %s',action);
end
end

function [e] = keymap(key)
switch key
    case 'left'
        e = java.awt.event.KeyEvent.VK_LEFT;
    case 'right'
        e = java.awt.event.KeyEvent.VK_RIGHT;
    case 'enter'
        e = java.awt.event.KeyEvent.VK_ENTER;
    case 'a'
        e = java.awt.event.KeyEvent.VK_A;
    case 'b'
        e = java.awt.event.KeyEvent.VK_B;
    otherwise
        error('unknown key: %s',key);
end
end