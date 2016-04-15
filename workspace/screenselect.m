function [x,y,w,h] = screenselect()
javax.swing.UIManager.setLookAndFeel(javax.swing.UIManager.getCrossPlatformLookAndFeelClassName());
javax.swing.JFrame.setDefaultLookAndFeelDecorated(1);
jf = javax.swing.JFrame();
jf.setUndecorated(1);
jf.setOpacity(0.5);
jf.setSize(500,500);
jf.setVisible(1);

h = msgbox('press ok or close this window when done');
uiwait(h);
% set(jf,'WindowClosingCallback', 'uiresume(h)');

jfsize = jf.getSize();
jfloc = jf.getLocationOnScreen();

jf.setVisible(0);
jf.dispose();
javax.swing.JFrame.setDefaultLookAndFeelDecorated(0);
javax.swing.UIManager.setLookAndFeel(javax.swing.UIManager.getSystemLookAndFeelClassName())

x = jfloc.x;
y = jfloc.y;
w = jfsize.width;
h = jfsize.height;
end

