function out_im = mydilate(im, s_e)
se = s_e.Neighborhood;
[m, n] = size(se);
m = floor(m/2);
n = floor(n/2);
[M, N] = size(im);
out_im = zeros(M,N);
for i = (1+m):(M-m)
    for c = (1+n):(N-n)
        out_im(i, c) = max(max(im(i-m:i+m, c-n:c+n).*se));
    end
end
end

