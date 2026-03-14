function [X_FT_OFDM_estimated] = MMSE_FT(Y_FT_OFDM, H_ft_OFDM, sigma_2)

h_ft = H_ft_OFDM(:);
y = Y_FT_OFDM(:);

w_mmse = conj(h_ft)./(abs(h_ft).^2 + sigma_2);
x = y.*w_mmse;
X_FT_OFDM_estimated = reshape(x, size(Y_FT_OFDM));


end