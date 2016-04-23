
Img = double(imread('Critical_interference_test.png'));
Img = Img(:,:,1);
Img = im2bw(Img, 0.5);
square_center = [round((896+785)/2), round((480+592)/2)];
CropImg = Img(square_center(2) - 110 : square_center(2) + 110, square_center(1) - 110 : square_center(1) + 110);


tic
for i = 1:200
    centerbox_orig;
end
toc

%{
tic
for i = 1:2000
    centerbox1;
end
toc
%}

%{
tic
for i = 1:1000
    centerbox2;
end
toc
%}

%{
tic
for i = 1:2000
    centerbox3;
end
toc
%}

%{
tic
for i = 1:200
    centerbox4;
end
toc
%}

tic
for i = 1:200
    centerbox5;
end
toc

tic
for i = 1:200
    centerboxFinal(CropImg);
end
toc
