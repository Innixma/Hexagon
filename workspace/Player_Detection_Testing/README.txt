Detect_Player_v1-4 are hard coded for the following conditions:
Running OpenHexagons in near fullscreen with some vertical offset due to the 'near' part.  See screenshots to see offset.
Screen resolution = 1680 x 1050
All current versions act on the thresholded image, not the edge thinned one.  
Versions 1-3 take in screenshot stills.  As the are scripts, the screenshot fed to them can be changed by commenting and 
uncommenting the relevant lines at the beginning.
Version 1 searches small patches in a square ring around the center, looking for a certain number of on pixels. Most of the 
patches have all pixels on; some will have most to all off, denoting a region where there is a wall (not currently used
 for wall detection).  If the number lies within a critical region, that is where the player is said to be.  Version 1 marks
the search region and the detected player.  To see the detected player before it gets covered up by the search region plotting, 
make sure to put a debug point on line 64 (where it says "debug = 3").  Continue after that to see the full search region,
which is the longest step of the function

Version 2 corrects Version 1's mistake by looking in an annulus corresponding to the player's possible locations rather than a
square.  It can also be run to mark the search region and the detected player. To see the detected player before it gets
 covered up by the search region plotting, make sure to put a debug point on line 93 (where it says "debug = 1").

Version 3 is basically Version 2 without the plotting.  It is the fastest version because it does not waste time on plotting
anything. It finds the x and y coordinates of the center of the player.  

Version 4 is the function version of Version 3.  It is the first step toward integrating this patch-search player detection 
algorithm with the rest of the project.  It takes in an image vector (by imread, or screencapture) which has been cropped 
around the orbital center and outputs the x and y coordinates of the center of the player.  Version 4 also plots the results.
    Version 4 has an associated driver script, v4_test_driver.m which crops a sample image and passes it to Version 4.

Version 5 is Version 4 made dimensionless.  It has a driver script, v5_test_driver.m which is analogous to v4_test_driver.m

