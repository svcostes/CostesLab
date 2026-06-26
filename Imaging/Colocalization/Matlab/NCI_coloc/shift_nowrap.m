function img2 = shift_nowrap(img1,vect);

w1 = size(img1,1);
h1 = size(img1,2);
d1 = size(img1,3);
img1 = reshape(img1,[w1,h1,d1]);

img2 = newim(size(img1));

xmin = max([0,vect(1)]);
xmax = min([w1-1,w1+vect(1)-1]);

ymin = max([0,vect(2)]);
ymax = min([h1-1,h1+vect(2)-1]);

zmin = max([0,vect(3)]);
zmax = min([d1-1,d1+vect(3)-1]);

img2(xmin:xmax,ymin:ymax,zmin:zmax) = img1(xmin-vect(1):xmax-vect(1),ymin-vect(2):ymax-vect(2),zmin-vect(3):zmax-vect(3));