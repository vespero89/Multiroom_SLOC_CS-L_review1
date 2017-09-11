function b = square_sum_of_distances_2(v,points,POS)
% define function sum of squared distances
% input args = points of intersection between the straight line DOA and the wall of the room
x = v(1);
y = v(2);
p1 = POS(1,:);
p2 = points(1:2);
p3 = POS(2,:);
p4 = points(3:4);
p5 = POS(3,:);
p6 = points(5:6);
p7 = POS(4,:);
p8 = points(7:8);
p9 = POS(5,:);
p10 = points(9:10);
pm = [x,y];

d1 = abs( det([pm-p1;p2-p1]) )/norm(p2-p1);
d2 = abs( det([pm-p3;p4-p3]) )/norm(p4-p3);
d3 = abs( det([pm-p5;p6-p5]) )/norm(p6-p5);
d4 = abs( det([pm-p7;p8-p7]) )/norm(p8-p7);
d5 = abs( det([pm-p9;p10-p9]) )/norm(p10-p9);

b = sqrt(d1^2 + d2^2 + d3^2 + d4^2 + d5^2);

end