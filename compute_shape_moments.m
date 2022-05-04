function moment = compute_shape_moments(img, mom_num)

ROI = segment_spiral(img);
switch mom_num
    case 1
        moment = compute_nu(ROI, 2, 0) + compute_nu(ROI, 0, 2);
    case 2
        tmp = compute_nu(ROI, 2, 0) - compute_nu(ROI, 0, 2);
        moment = tmp^2 + 4*compute_nu(ROI, 1, 1)^2;
    case 3
        moment = (compute_nu(ROI, 3, 0) - 3*compute_nu(ROI, 1, 2))^2 + ...
            (3*compute_nu(ROI, 2, 1) - compute_nu(ROI, 0, 3))^2;
    case 4
        moment = (compute_nu(ROI, 3, 0) + compute_nu(ROI, 1, 2))^2 + ...
            (compute_nu(ROI, 2, 1) + compute_nu(ROI, 0, 3))^2;
end
tmp = compute_nu(ROI, 2, 0) - compute_nu(ROI, 0, 2);
moment2 = tmp^2 + 4*compute_nu(ROI, 1, 1)^2;
moment = moment/(moment2^(mom_num/2));
end

function nu = compute_nu(ROI, ord_x, ord_y)

    % Compute centroid of the binary shape
    stats = regionprops(ROI);
    centroid = stats.Centroid;

    % Save coordinates of the pixels == 1
    [x, y] = find(ROI==1);
    
    % Computing distance from every pixel to the centroid
    nu = sum(((x-centroid(1)).^ord_x).*((y-centroid(2)).^ord_y), 'all');
end