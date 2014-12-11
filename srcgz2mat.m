function [image, btable, vs, mat] = srcgz2mat(srcgz_file)
%
% [mat] = srcgz2mat(srcgz_file)
%
% This function transform file structure .src.gz to .mat. 
%
% EXAMLE
%
% srcgz_file = 'sdeq.src.gz';
% [image, btable, vs, mat] = srcgz2mat(srcgz_file)
%

%% argument check
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
% [~,name] = fileparts(name);

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
btable = b_table;
vs = voxel_size;
end