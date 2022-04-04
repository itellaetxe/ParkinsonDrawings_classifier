function stroke_width = measure_stroke_width(img)

    thr = graythresh(img);
    Dist = bwdist(imclose(img<thr, strel('disk', 1)));
    RegionMax = imregionalmax(Dist);
    [x, y] = find(RegionMax ~= 0);
    imshow(Dist);
    List(1:size(x))=0;
    
    for i = 1:size(x) 
        List(i)=Dist(x(i),y(i));
    end
    stroke_width = mean(List)*2;
end