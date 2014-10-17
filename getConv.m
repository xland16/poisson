%Tom Crossland
function [c] = getConv(S,T);
[Sm Sn] = size(S);
[Tm Tn] = size(T);

if mod(Sm,2) ~= 0
    S = padarray(S,[1 0],0,'post');
end
if mod(Sn,2) ~= 0
    S = padarray(S,[0 1],0,'post');
end
if mod(Tm,2) ~= 0
    T = padarray(T,[1 0],0,'post');
end
if mod(Tn,2) ~= 0
    T = padarray(T,[0 1],0,'post');
end

% Find the next highest power of 2 to pad the matrices to
m = pow2(nextpow2(Sm+2*Tm));
n = pow2(nextpow2(Sn+2*Tn));

% Find the padlength in one direction for S
i = floor((m-Sm)/2);
j = floor((n-Sn)/2);

% Pad S
S = padarray(S,[i j]);

% Find the padlength in one direction for T and the mask
h = floor((m-Tm)/2);
k = floor((n-Tn)/2);

% Pad T
T = padarray(T,[h k]);

% Fourier transform the matrices
S = fftshift(S);
fS = fft2(S);
fT = fft2(T);

% Perform convolution and inverse Fourier the results
c = ifft2(fS.*fT);
c = c(i+1:i+Sm,j+1:j+Sn);

end