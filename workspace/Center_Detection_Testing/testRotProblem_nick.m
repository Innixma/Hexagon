tic
load('centerImg_5side');
toc


tic
for i = 1:100
%figure; imshow(centerImg);
[centerSize, numSides, wallAngles] = real_centerbox_final_nick5(centerImg);
end
toc


%load('centerImg_5side');
tic
for i = 1:100
%figure; imshow(centerImg);
[centerSize, numSides, wallAngles] = real_centerbox_final_nick3(centerImg);
end
toc




