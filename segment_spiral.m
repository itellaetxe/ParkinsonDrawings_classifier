function ROI = segment_spiral(img)
%SEGMENT_SPIRAL Segments the spiral.
if size(img, 1) > 500
    im = imresize(img, 0.25); % Irudi sintetikoak resize!!!
end

% Simple thresholding, non-uniform lighting was not found.
T = graythresh(img);
ROI = img < T;
ROI = imclose(ROI, strel("square", 4));

% Delete elements with less than 100 pixels. (Sometimes, there are numbers 
% in our synthetic spirals. Sorry)
ROI = bwareaopen(ROI, 100, 8);

end

