function [H,Tv] = find_rays(M,n,low,high)

% create image B by selecting values in M between high, low
B = M .* (M > low) .* (M < high);
% normalize B
B = B - min(B(:));
B = B ./ max(B(:));
% edge detection on B
E = edge(B);

tic;
[H,T] = hough_rays(E);
toc;

fprintf('displaying...\n');

% sort to find top scoring parameters
[~,Ht] = sort(H(:),'descend');
% only use the top n
Ht = Ht(1:n);

% get top theta indices
Ti = ind2sub(size(H), Ht);
% get top theta values
Tv = T(Ti);

% shift parameters for plotting
Tv = Tv + pi/2;

x0 = size(M,2) / 2;
y0 = size(M,1) / 2;

% display the image
imshow(M);
hold on;

% plot all the the lines given by top thetas
X = 0:1:size(M,2);
f = @(t,x) csc(t)*(-x*cos(t)+x0*cos(t)+y0*sin(t));
for i = 1:size(Ti)
    plot(X, f(Tv(i),X));
end
hold off;

end

