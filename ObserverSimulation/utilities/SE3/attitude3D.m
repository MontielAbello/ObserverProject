function a = attitude3D(p1,p2)
%computes the attitude of the segment defined by p1 and p2
% the origine is p1
up = [0,1,0]'; % y axis is up
d = p2 - p1;
d = norm3Dvect(d);
u = [0,1,0]'- dot(up,d) * d;
u = norm3Dvect(u);
r = cross (d,u);
% if (norm(r)< 1e-10)
%     r=up;
% end
R = [r,u,d];
a = arot(R);

% a_temp = vrrotvec( (p2-p1),[0 0 1]');
% a_temp = a(1:3)./a(4);

end

function vec_n = norm3Dvect(vec)
norm_vec = norm(vec);
if (norm_vec <= 0)
    vec_n = zeros(size(vec));
else
    vec_n = vec ./ norm_vec;
end
end
