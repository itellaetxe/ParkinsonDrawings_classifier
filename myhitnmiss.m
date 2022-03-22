function out_im = myhitnmiss(image, element, dirs)
% Values for combinations to sum and code in LUT
vals = [1, 8, 64;
        2, 16, 128;
        4, 32, 256];
% Make all combinations of the input element respect to the vals
for i = 1:dirs - 1
element(:,:,i+1) = imrotate(element(:,:,i), 360/dirs * i, 'crop');
end
for i = 1:dirs
combs(i) = sum(sum(element(:,:,i) .* vals)) + 1;
end
% Input values in LUT
LUT = zeros(1, 2^(size(vals, 1) * size(vals, 2)));
LUT(combs) = 1;

% Apply this to image subregions
[m, n] = size(element(:,:,1));
out_im = zeros(m, n);
m = floor(m/2);
n = floor(n/2);
[M, N] = size(image);

for i = (1+m):(M-m)
    for c = (1+n):(N-n)
        V = sum(sum(image(i-m:i+m, c-n:c+n) .* vals));
        if V == 0
            out_im(i,c) = LUT(V + 1);
        else
            out_im(i,c) = LUT(V + 1);
        end
    end
end





