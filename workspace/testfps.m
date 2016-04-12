function [] = testfps(w,h,frames)
fprintf('processing...\n');
tic;
for i = 1:frames
    screencapture(0, 0, w, h);
end
t = toc;
fps = frames / t;
fprintf('captured %d frames in %f seconds\n', frames, t');
fprintf('performance ~%.1f fps\n', round(fps,1));
end
