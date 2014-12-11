function [image btable vs]= read_src(file_name)
if ~exist('file_name')
    file_name =  uigetfile('*.src.gz');
end
if file_name == 0
    image = [];
    return
end
gunzip(file_name);
[pathstr, name, ext] = fileparts(file_name);
movefile(name,strcat(name,'.mat'));
load(strcat(name,'.mat'));
bsize = size(b_table);
image = zeros([dimension bsize(2)]);
for i = 1:bsize(2)
    eval(strcat('image(:,:,:,',int2str(i),')=reshape(image',int2str(i-1),',dimension);'));
    eval(strcat('clear image',int2str(i-1)));
end
delete(strcat(name,'.mat'));
btable = b_table;
vs = voxel_size;
end