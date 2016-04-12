function [H,Tr] = hough_rays(E,tbinres)
if nargin == 1;
    tbinres = 1;
end
tbins = ceil(180 * tbinres);

[Tr,tbinmap] = bin(-pi,pi,tbins);

x0 = size(E,2) / 2;
y0 = size(E,1) / 2;

H = zeros(tbins);

[Y,X] = find(E);
Y = Y'; X = X';
T = atan2(Y-y0,X-x0);
Ti = arrayfun(tbinmap,T);
for ti = Ti
    H(ti) = H(ti) + 1;
end

end

function [table,map,step] = bin(vmin, vmax, bins)
diff = abs(vmax - vmin);
step = diff / (bins-1);
table = vmin:step:vmax;
map = @(v) round(((v-vmin) / diff) * (bins-1)) + 1;
end