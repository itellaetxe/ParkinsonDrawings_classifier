function out = myregiongrow(target_im, SE, hazia)
% NOT(target_im)
comp_A = not(target_im);

Xk = zeros(size(target_im));
for i = 1:length(hazia)
    Xk(hazia(i,2), hazia(i,1)) = 1;
end

Xk_n = mydilate(Xk, SE) .* comp_A;
while ~isequal(Xk_n, Xk)
    Xk = Xk_n;
    Xk_n = mydilate(Xk, SE) .* comp_A;
end

out = Xk | target_im;
end