w = input('width? ');
h = input('height? ');
frames = input('frames to capture? ');
fprintf('processing...\n');
t = 0;
tic;
for i = 1:frames
    img = screencapture(0, 0, w, h);
end
t = toc;
fps = frames / t;
fprintf('captured %d frames in %f seconds\n', frames, t');
fprintf('performance ~%.1f fps\n', round(fps,1));