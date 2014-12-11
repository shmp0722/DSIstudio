function p = find_peak(odf,odf_faces)
is_peak = odf;
odf_faces = odf_faces + 1;
odf_faces = odf_faces - (odf_faces > length(odf))*length(odf);
is_peak(odf_faces(1,odf(odf_faces(2,:)) >= odf(odf_faces(1,:)) | ...
    odf(odf_faces(3,:)) >= odf(odf_faces(1,:)))) = 0;
is_peak(odf_faces(2,odf(odf_faces(1,:)) >= odf(odf_faces(2,:)) | ...
    odf(odf_faces(3,:)) >= odf(odf_faces(2,:)))) = 0;
is_peak(odf_faces(3,odf(odf_faces(2,:)) >= odf(odf_faces(3,:)) | ...
    odf(odf_faces(1,:)) >= odf(odf_faces(3,:)))) = 0;
[values,ordering] = sort(-is_peak);
p = ordering(values < 0);
end
