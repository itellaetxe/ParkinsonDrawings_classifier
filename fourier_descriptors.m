function ff = fourier_descriptors(xlocs, ylocs)
N = length(xlocs);
% Preallocate S for speed
S = zeros(1, N);
for cK = 1:N
    S(cK) = xlocs(cK) + 1j * ylocs(cK);
end

% Compute spectrum
Z = fft(S, N);
Z(1) = 0; % Remove centroid, not useful.

% Normalize
Zn = Z / abs(Z(2) + Z(end));

% Get Rangayyan's "Magic" number "ff"
s_1 = 0; s_2 = 0;
for cI = 1:N/2-1
    s_1 = abs(Zn(cI+1)) / cI + abs(Zn(end-cI+1)) / cI + s_1; 
    s_2 = abs(Zn(cI+1)) + abs(Zn(end-cI+1)) + s_2;
end

ff = 1 - (s_1/s_2);
end