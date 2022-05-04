function [mean_stroke_width, variance_stroke_width] = measure_stroke_width(img)

if size(img, 1) > 500
    img = imresize(img, [256 256]); % Irudi sintetikoak resize!!!
end

% Basically, watershed transform.
thr = graythresh(img);
Dist = bwdist(imclose(img<thr, strel('disk', 1)));
RegionMax = imregionalmax(Dist);
[x, y] = find(RegionMax ~= 0);
% imshow(Dist);
List(1:size(x))=0;

for i = 1:size(x)
    List(i)=Dist(x(i),y(i));
end
mean_stroke_width = mean(List)*2;
variance_stroke_width = std(List)^2;
end