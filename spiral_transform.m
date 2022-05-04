function [HFP, ff, N_pruned_pixels, N_pixels_spiral] = ...
    spiral_transform(im, selfmade)
% SPIRAL_TRANSFORM. Gives Contour signature spectral analysis, and shape 
% descriptor (Rangayyan's number).

% Resize image if it is big (self-made spirals are big)

if size(im, 1) > 500
    im = imresize(im, 0.25); % Irudi sintetikoak resize!!!
end

% Simple thresholding, non-uniform lighting was not found.
T = graythresh(im);
ROI = im < T;
ROI = imclose(ROI, strel("square", 4));

% Delete elements with less than 100 pixels. (Sometimes, there are numbers 
% in our synthetic spirals. Sorry)
ROI = bwareaopen(ROI, 100, 8);

% Thin ther image as much as possible and prune it a bit to eliminate
% possible contour follower confounding branches.
skel_im = bwmorph(ROI, 'thin', Inf);
% Prune the skeleton
pruned_skel_im = bwmorph(skel_im, 'spur', 10);
N_pruned_pixels = sum(sum(xor(pruned_skel_im, skel_im))); % This could be a feature
% Then we try not to break the spiral by closing it (to connect possibly
% broken segments)
pruned_skel_im = imclose(pruned_skel_im, strel("square", 3));
% Remove the salt again (it can appear after pruning)
pruned_skel_im = bwareaopen(pruned_skel_im, 10);

% Feature: number of pixels in spiral
N_pixels_spiral = sum(pruned_skel_im(:));
%% Contour Signature using bwboundaries
ROI = pruned_skel_im;  % We rename our Region of Interest

% Get the biggest element
bigblob = bwareafilt(ROI, 1);
% Get centroid of biggest 
centroid = regionprops(bigblob, 'Centroid');
if selfmade == 1
    % Get the points that belong to it.
    points = bwboundaries(bigblob);

    points = points{1};
    % Save X & Y points in separate arrays
    Y_pts = points(:,1); X_pts= points(:,2);

    %% Self-made Contour-signature following spiral points (error-prone!)
    % This is our function for spiral following.
    % It is quite error prone... We tried our best.

    % First we need to get one of the starting points. Hit or miss.
    % No matter which one we take and the order of growing,
    % because we will look at the spectral information of the signal.
    % Of course, if we induce several big and abrupt changes high freq. content
    % will appear in the contoursig spectrum. Consider this!
else
    % Find endpoints and get the outermost one (no particular reason,
    % just to be consistent)
    hits = bwmorph(bigblob, 'endpoints'); [endpy, endpx] = find(hits);

    % Measure euclidean distance to center and take closest (closest point
    % from center)
    [M, N] = size(im);
    C = round(0.5*[M, N]);
    dists = sqrt((endpy-C(1)).^2 + (endpx-C(2)).^2); [~, closest] = min(dists);
    Y_init = endpy(closest); X_init = endpx(closest);

    % Take biggest spiral segment that we found
    canv_n = bigblob;
    canv_n = padarray(canv_n, [1,1], 0);
    pointy = Y_init + 1; pointx = X_init + 1; % Add 1 because we padded !!!

    % Start point tracking
    ci = 1; ck = 1;
    while ~isequal(canv_n, zeros(size(canv_n))) || ck > 5
        canv_n(pointy, pointx) = 0;
        p = find(canv_n(pointy-1:pointy+1, pointx-1:pointx+1));
        if isempty(p)
            break;
        end
        p = p(1);

        switch p
            case 1
                pointy = pointy - 1;
                pointx = pointx - 1;
            case 2
                pointx = pointx - 1;
            case 3
                pointy = pointy + 1;
                pointx = pointx - 1;
            case 4
                pointy = pointy - 1;
            case 6
                pointy = pointy + 1;
            case 7
                pointy = pointy - 1;
                pointx = pointx + 1;
            case 8
                pointx = pointx + 1;
            case 9
                pointy = pointy + 1;
                pointx = pointx + 1;
        end
        X_pts(ck, ci) = pointx;
        Y_pts(ck, ci) = pointy;

        ci = ci + 1;
    end
end
% Compute contour signature
contourSig = sqrt((X_pts-centroid.Centroid(1)).^2 + ...
    (Y_pts-centroid.Centroid(2)).^2);

% Compute spectrum of contour signature
spec = fft(contourSig, length(contourSig));
half = round(length(spec) / 2);
spec = spec(1:half);
spec = abs(spec);
% Ratio of high frequency power accounting for fast varying coordinates, tremor of
% the hand, respect to whole spectrum.
th = ceil(length(spec) / 100); % th is at 1% of the spectrum bandwith.
if th == 1; th = 2; end
HFP = sum(spec(th:end)) / sum(spec);

% % New feature: distance from centroid of figure spiral's inner endpoint. If
% % the spiral is properly drawn, this should be minimized. If not, it gets
% % bigger. (Hypothesis!). Let's call it IECD
% % (inner-endpoint-centroid-distance) %%% NEEDS TO BE DISCUSSED!
% IECD = sqrt((centroid.Centroid(1)-X_init).^2 + (centroid.Centroid(2)-Y_init).^2);


% Rangayyan's ff number just in case it turns out to be supa good.
ff = fourier_descriptors(X_pts, Y_pts);
end

