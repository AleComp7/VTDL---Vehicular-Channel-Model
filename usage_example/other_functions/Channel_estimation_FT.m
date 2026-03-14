function [H_tf] = Channel_estimation_FT(R, X)

% R is the FFT-transformed signal output of the channel, without noise
% X is the freq-time domain signal generated at the tx side

% Perfect CSI
H_tf = (R).*conj(X)./(abs(X).^2); 

end