function [H,Tv] = find_lines(M,n,low,high)
B = normalize(M .* (M > low) .* (M < high));
E = edge(B);

tic;
[H,T] = hough_rays(E);
toc;

fprintf('displaying...\n');

[~,Ht] = sort(H(:),'descend');
Ht = Ht(1:n);

Ti = ind2sub(size(H), Ht);
Tv = T(Ti);

Tv = Tv + pi/2;

x0 = size(M,2) / 2;
y0 = size(M,1) / 2;

imshow(M);
hold on;
X = 0:1:size(M,2);
f = @(t,x) csc(t)*(-x*cos(t)+x0*cos(t)+y0*sin(t));
for i = 1:size(Ti)
    plot(X, f(Tv(i),X));
end
hold off;

end

