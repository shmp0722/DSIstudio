function [image, btable, vs, mat]= read_src(file_name)
%
% This function returns image (= nifti.data), btable(bvals, bvecs), and vs.
%
% EXAMPLE
% 
% file_file = 'SE_diffusion_weighted.src.gz';
% [image, btable, vs, mat]= read_src(file_name);
% 
% SO @Vista lab 2014

if ~exist('file_name')
    file_name =  uigetfile('*.src.gz');
end
if file_name == 0
    image = [];
    return
end

% unzip .gz file
gunzip(file_name);

% remove extension form original file name
[pathstr, name, ext] = fileparts(file_name);
[~,nameWoExt] = fileparts(name);

% transform .src.gz into .mat 
movefile(name,strcat(name,'.mat'));
load(strcat(name,'.mat'));

% Get image and 
bsize = size(b_table);
image = zeros([dimension bsize(2)]);
for i = 1:bsize(2)
    eval(strcat('image(:,:,:,',int2str(i),')=reshape(image',int2str(i-1),',dimension);'));
    eval(strcat('clear image',int2str(i-1)));
end
% delete(strcat(name,'.mat'));
movefile([name,'.mat'],strcat(nameWoExt,'.mat'));
btable = b_table;
vs = voxel_size;
end