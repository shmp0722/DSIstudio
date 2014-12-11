function gqi_reco(filename,file_type,pixel_size,b_table,mean_diffusion_distance_ratio)
% Direct GQI reconstruction from huge image data
% You may need to include find_peak.m to run these codes.
% parameters:
% 	filename: the filename of the image volume
% 	file_type: the pixel format of the image, can be 'int8', 'int16', 'int32', 'single', or 'double'
% 	pixel_size: the size of the pixel in bytes.  
% 	b_table: the b-table matrix with size of 4-by-d, where d is the number of the diffusion weighted images
%          b(1,:) stores the b-value, whereas b(2:4,:) stores the grandient vector
% 	mean_diffusion_distance_ratio: check out GQI reconstruction for detail. Recommended value=1.2  
% 
% example:
% 	gqi_reco('2dseq','int32',4,b_table,1.0);

load odf8.mat;

% you may need to change the dimension, number of diffusion images, and voxel size
dim = [128 128 128];
dif = 515;
voxel_size = [6/128 6/128 6/128];

fa0 = zeros(dim);
fa1 = zeros(dim);
fa2 = zeros(dim);
index0 = zeros(dim);
index1 = zeros(dim);
index2 = zeros(dim);

reco_temp = zeros(dim(1),dim(2),dif);
plane_size = dim(1)*dim(2);

% GQI reconstruciton matrix A
l_values = sqrt(b_table(1,:)*0.01506);
b_vector = b_table(2:4,:).*repmat(l_values,3,1);
A = sinc(odf_vertices'*b_vector*mean_diffusion_distance_ratio/pi);

f =fopen(filename);
max_dif = 0;
for z = 1:dim(3)
    for d = 1:dif
        fseek(f,((z-1)*plane_size+(d-1)*dim(1)*dim(2)*dim(3))*pixel_size,'bof');
        reco_temp(:,:,d) = reshape(fread(f,plane_size,file_type),dim(1),dim(2));
    end
    for x = 1:dim(1)
        for y = 1:dim(2)
            ODF=A*reshape(reco_temp(x,y,:),[],1);
            p = find_peak(ODF,odf_faces);
            max_dif = max(max_dif,mean(ODF));
            min_odf = min(ODF); 
            fa0(x,y,z) = ODF(p(1))-min_odf;
            index0(x,y,z) = p(1)-1;
            if length(p) > 1
                fa1(x,y,z) = ODF(p(2))-min_odf;
                index1(x,y,z) = p(2)-1;
            end
            if length(p) > 2
                fa2(x,y,z) = ODF(p(3))-min_odf;
                index2(x,y,z) = p(3)-1;
            end
        end
    end
end
fa0 = fa0/max_dif;
fa1 = fa1/max_dif;
fa2 = fa2/max_dif;
fa0 = reshape(fa0,1,[]);
fa1 = reshape(fa1,1,[]);
fa2 = reshape(fa2,1,[]);
index0 = reshape(index0,1,[]);
index1 = reshape(index1,1,[]);
index2 = reshape(index2,1,[]);
dimension = dim;
save('result.fib','dimension','voxel_size','fa0','fa1','fa2','index0','index1','index2','odf_vertices','odf_faces','-v4');
fclose(f);
end