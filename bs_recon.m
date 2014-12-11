function bs_recon()
file_name =  uigetfile('*.src.gz');
if file_name == 0
    return
end
[image b_table voxel_size] = read_src(file_name);
dimension = size(image);
dimension = dimension(1:3);
image_size = prod(dimension);
image = reshape(image,image_size,[]);
index = reshape(index,image_size,[]);
dir0 = zeros(3,image_size);
dir1 = zeros(3,image_size);
fa0 = zeros(1,image_size);
fa1 = zeros(1,image_size);

parfor_progress(image_size);

parfor i = 1:image_size
            fa_values = fa(i,:);
            indicies = index(i,:);
            d1 = odf_vertices(:,indicies(1)+1);
            d2 = odf_vertices(:,indicies(2)+1);
            sol = resolve_fiber_at(image,b_table,i,fa_values(1),fa_values(2),d1,d2);
            [a b c] = sph2cart(sol(3),sol(4),1);
            dir0(:,i) = [a b c];
            [a b c] = sph2cart(sol(5),sol(6),1);
            dir1(:,i) = [a b c];
            fa0(i) = sol(1);
            fa1(i) = sol(2);
            if fa1(i) > fa0(i)
                t = fa1(i);
                fa1(i) = fa0(i);
                fa0(i) = t;
                t = dir1(:,i);
                dir1(:,i) = dir0(:,i);
                dir0(:,i) = t;
            end
            if fa1(i) < 0.0001
               fa1(i) = 0;
            end
            
            parfor_progress;
            
end
clear image;
s.dimension = dimension;
s.fa0 = reshape(fa0,1,[]);
s.fa1 = reshape(fa1,1,[]);
s.dir0 = reshape(dir0,3,[]);
s.dir1 = reshape(dir1,3,[]);
s.voxel_size = voxel_size;
save(strcat(file_name,'.ball_stick.fib'),'-struct','s','-v4');
gzip(strcat(file_name,'.ball_stick.fib'));
delete(strcat(file_name,'.ball_stick.fib'));
end


function x = resolve_fiber_at(image,b_table,i,f1,f2,dir1,dir2)

signals = reshape(image(i,:),1,[]);
b_value = b_table(1,:);
b0_signal = mean(signals(b_value ==0));
signals = signals/b0_signal;
% define the cost function
[s1 s2] = cart2sph(dir1(1),dir1(2),dir1(3));
[s3 s4] = cart2sph(dir2(1),dir2(2),dir2(3));
x = [0.8*f1/(f1+f2) 0.8*f2/(f1+f2)  s1 s2 s3 s4 1.0000 1.0000 1.0000];
%x = fminsearch(f,x);
%f = @(x) norm(signals-ball_stick(b_table,x)',2);
%x = fmincon(f,x,[],[],[],[],[0 0 -pi -pi -pi -pi 0 0 0],[1 1 pi pi pi pi 10 10 10],@bs_con,optimset('Algorithm','interior-point','Display','off'));
f = @(x,x_data) ball_stick(x_data,x)';
x = lsqcurvefit(f,x,b_table,signals,[0 0 -pi -pi -pi -pi 0 0 0],[1 1 pi pi pi pi 10 10 10],optimset('Display','off'));
end

function signal = ball_stick(b_table,x)
%      1  2  3    4   5    6    7  8  9
%x = [f1,f2,dir1,dir1,dir2,dir2,l0,l1,l2]
[dir1(1) dir1(2) dir1(3)] = sph2cart(x(3),x(4),1);
[dir2(1) dir2(2) dir2(3)] = sph2cart(x(5),x(6),1);
% generate signals
b = b_table(1,:)'/1000;
cos1 = b_table(2:4,:)'*dir1';
cos2 = b_table(2:4,:)'*dir2';
signal = x(1)*exp(cos1.*cos1.*-b*x(8)) + x(2)*exp(cos2.*cos2.*-b*x(9)) + (1-x(1)-x(2))*exp(-b*x(7));
signal = signal/signal(b == 0);
end
function [c, ceq] = bs_con(x)
% Nonlinear inequality constraints
% must < 0
c = [x(1) + x(2) - 1];
% Nonlinear equality constraints
ceq = [];
end